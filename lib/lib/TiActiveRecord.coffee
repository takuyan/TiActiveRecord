#
# Copyright 2012 Takuya Kato.
#
# module class is define: http://arcturo.github.com/library/coffeescript/03_classes.html
moduleKeywords = ['extended', 'included']

class Module
  @extend: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this

classProperties =

  init: ->
    sql = "CREATE TABLE IF NOT EXISTS #{@tableName} ("
    i = 0
    for k, v of @tableProperties()
      column = "#{k} #{v}"
      sql += column if i == 0
      sql += "," + column if i > 0
      i++
    sql += ");"

    Ti.API.debug "table init script: #{sql}"

    db = @installDb()
    db.execute sql
    db.close()

  build: (params={}) ->
    obj = Object.create @::
    for c in @columns()
      obj[c] =
        if params[c]
          params[c]
        else
          null
    obj

  create: (params) ->
    obj = @build(params)
    obj.save()
    obj

  columns: ->
    (k for k, v of @tableProperties())

  #
  # If @remove_auto_increment = true, AUTOINCREMENT is not define on id column
  # If @remove_primary_key = true, PRIMARY KEY is not define on id column
  #
  tableProperties: ->
    properties = Object.create @properties
    for k, v of @defaultProperties
      if k == 'id'
        if @remove_auto_increment
          v = v.replace /AUTOINCREMENT/, ''
        if @remove_primary_key
          v = v.replace /PRIMARY KEY/, ''
        properties[k] = v
      else
        properties[k] = v
    properties

  installDb: ->
    if Ti.Platform.osname == 'android'
      db = Ti.Database.install("/#{@dbName}.sql", "#{@dbName}Installed")
    else
      db = Ti.Database.install("#{@dbName}.sql", "#{@dbName}Installed")

  read: (sql, data) ->
    Ti.API.debug "[READ] #{sql} <= #{data}"
    db = @installDb()
    if data
      resultSet = db.execute sql, data
    else
      resultSet = db.execute sql
    results = []
    while resultSet.isValidRow()
      result = @build()
      for name in @columns()
        result[name] = resultSet.fieldByName name
      results.push result
      resultSet.next()
    resultSet.close()
    db.close()
    results

  first: ->
    sql = "SELECT * FROM #{@tableName} ORDER BY ID DESC LIMIT 1"
    data = @read(sql)
    data[0]

  last: ->
    sql = "SELECT * FROM #{@tableName} ORDER BY ID ASC LIMIT 1"
    data = @read(sql)
    data[0]

  all: ->
    sql = "SELECT * FROM #{@tableName} ORDER BY ID DESC"
    @read(sql)

  find_by_id: (id)->
    sql = "SELECT * FROM #{@tableName} WHERE ID = ?"
    data = @read(sql, id)
    return data[0]

  find: (params) ->
    sql = "SELECT * FROM #{@tableName}"
    if params instanceof Number
      id = params
      sql += " WHERE ID = ?"
      return @read sql, id
    else
      keys = []
      vals = []
      orderby = ""
      for key, value of params
        if key == 'order'
          orderby = " ORDER BY #{value}"
        else
          keys.push key
          vals.push value

      if keys.length > 0
        sql += " WHERE "
        wheres = []
        for key in keys
          wheres.push key + " = ?"
        sql += wheres.join(',')
      sql += orderby
      return @read(sql, vals)

  deleteAll: (params) ->
    sql = "DELETE FROM #{@tableName}"
    keys = []
    vals = []
    for key, value of params
      keys.push key
      vals.push value

    if keys.length > 0
      sql += " WHERE "
      wheres = []
      for key in keys
        wheres.push key + " = ?"
      sql += wheres.join(',')

    Ti.API.debug "[DELETE] [ALL] #{sql} <= #{(v for v in vals).join(', ')}"

    db = @installDb()
    db.execute sql, vals
    db.close()

instanceProperties =

  isNewRecord: ->
    if @id
      false
    else
      true

  increment: (name) ->
    if @[name] == null
      @[name] = 1
    else
      @[name] += 1
    @save()

  destroy: ->
    if @isNewRecord()
      Ti.API.debug "[DELETE][WARN] Not saved object can not delete"
      false
    else
      sql = "DELETE FROM #{@constructor.tableName} WHERE ID = ?"
      db = @constructor.installDb()
      db.execute(sql, @id)
      Ti.API.debug "[DELETE] #{sql}, #{@id}"
      db.close()

  save: ->

    #
    # private instance method
    #
    create = =>

      columns = []
      vals = []
      data = []
      for c in @constructor.columns()
        columns.push c
        vals.push '?'
        if c == 'id'
          columns.pop()
          vals.pop()
          continue
        else if c == 'created_at'
          vals.pop()
          vals.push "datetime('now', 'localtime')"
        else if c ==  'updated_at'
          vals.pop()
          vals.push "datetime('now', 'localtime')"
        else if @[c]
          data.push @[c]
        else
          data.push null

      sql = "INSERT INTO #{@constructor.tableName} (#{columns.join(',')}  ) VALUES (#{vals.join(',')});"
      Ti.API.debug "[SAVE][INSERT] #{sql} <= #{data}"

      db = @constructor.installDb()
      db.execute(sql, data)
      @id = db.lastInsertRowId
      db.close()

      @reload()

    #
    # private instance method
    #
    update = =>

      sql = "UPDATE #{@constructor.tableName} "
      setter = []
      data = []
      for c in @constructor.columns()
        if c == 'id'
          continue
        else if c == 'created_at'
          continue
        else if c == 'updated_at'
          setter.push c + " = datetime('now', 'localtime')"
        else
          setter.push c + " = ?"
          data.push @[c] || null
      data.push @id
      sql += " SET " + setter.join(',')
      sql += " WHERE ID = ?;"

      db = @constructor.installDb()
      db.execute(sql, data)
      db.close()

      @reload()

    #
    # private instance method
    #
    create_or_update = =>

      if @isNewRecord()
        create()
      else
        update()

    #
    # save: ->
    #
    create_or_update()

  reload: ->
    if @isNewRecord()
      null
    else
      sql = ""
      cols = []
      vals = []
      newObj = {}
      sql = "SELECT * FROM #{@constructor.tableName} WHERE ID = ?;"
      newObj = @constructor.read(sql, @id)[0]
      for k, v of newObj
        @[k] = v
      @

class TiActiveRecord extends Module

  @extend classProperties
  @include instanceProperties

  @defaultProperties =
    id: 'INTEGER PRIMARY KEY AUTOINCREMENT'
    created_at: 'DATETIME'
    updated_at: 'DATETIME'

  #
  # TODO: Not Imprement yet
  #
  @dynamicFinders = ->
    dynamic = {}
    for column in @columns()
      #
      # TODO: Need 'Eval' Power !! but, performance ...?
      #
      # like this:
      #
      #   evalStr = "function(val) {
      #     var data, query;
      #     query = {};
      #     query[#{column}] = val;
      #     data = this.find(query);
      #     return data[0];
      #   };"
      #   dynamic["find_by_#{column}"] = evalStr
      #

      dynamic["find_by_#{column}"] = (val) ->
        query = {}
        query[column] = val
        data = @find query
        data[0]

      dynamic["find_all_by_#{column}"] = (val) ->
        query = {}
        query[column] = val
        @find query

    @extend dynamic

module.exports = TiActiveRecord
