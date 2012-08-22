# TiActiveRecord

Active Record Pattern of CoffeeScript for Titanium.

# Example

`sample1.coffee`

    a1 = Article.build
      uid: 10
      title: 'Awesome Article'
      body: 'Lorem Ipsum...'
      user_id: 8

    a1.isNewRecord() # => true

    a1.save()

    a1.isNewRecord() # => false

***

`sample2.coffee`

    a2 = Article.find 1

    a2.id # => 1
    a2.uid # => 10
    a2.title # => 'Awesome Article'
    a2.body # => 'Lorem Ipsum...'
    a2.user_id # => 8
    a2.created_at # => 2012-08-20 20:20:20
    a2.updated_at # => 2012-08-20 20:20:20

    a2.destroy()

***

`sample3.coffee`

    a3 = Article.create
      uid: 3
      title: 'Wonderful Article'
      body: 'lorem ipsum...'
      user_id: 3

    a3.isNewRecord() # => false

***

`sample4.coffee`

    articles = Article.all()

    someUsersArticles = Article.find
      user_id: 1

    someUsersArticles.length # => 3

    Article.deleteAll
      user_id: 3

## Model Setup

    #
    # lib/models/article.coffee
    # => Resources/models/article.js
    #
    TiActiveRecord = require 'lib/TiActiveRecord'

    class Article extends TiActiveRecord

      @dbName = 'myapp'
      @tableName = 'articles'
      @properties =
        uid: 'integer'
        title: 'text'
        body: 'text'
        image_url: 'text'
        image_name: 'text'
        pv: 'integer'

    Article.init()

    module.exports = Article

## Easy Extend

    #
    # lib/models/article.coffee
    # => Resources/models/article.js
    #
    TiActiveRecord = require 'lib/TiActiveRecord'

    class Article extends TiActiveRecord

      @dbName = 'myapp'
      @tableName = 'articles'
      @properties =
        uid: 'integer'
        title: 'text'
        body: 'text'
        image_url: 'text'
        image_name: 'text'
        pv: 'integer'

      #
      # class method
      #
      @findAllByUserId = (userId) ->
        sql = "SELECT * FROM #{@tableName} WHERE USER_ID = ?"
        @read sql, userId

      #
      # instance method
      #
      getImageDir: ->
        imageDir = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, "article#{@uid}")
        unless imageDir.exists()
          imageDir.createDirectory()
        imageDir

    Article.init()

    module.exports = Article

## Usage

Dowonload `lib/lib/TiActiveRecord.coffee`,  and compile to javascript.

or

if you use Git, clone this project on Titanium Mobile project root directory.

    $ git clone git://github.com/takuyan/TiActiveRecord.git coffee
    $ cd coffee
    $ bundle install
    $ bundle exec guard


