# TiActiveRecord

Active Record for Titanium

# Usage

    a1 = Article.build
      uid: 10
      title: 'Awesome Article'
      body: 'Lorem Ipsum...'
      user_id: 8

    a1.isNewRecord() # => true

    a1.save()

    a1.isNewRecord() # => false

***

    a2 = Article.find 1

    a2.id # => 1
    a2.uid # => 10
    a2.title # => 'Awesome Article'
    a2.body # => 'Lorem Ipsum...'
    a2.user_id # => 8

    a2.destroy()

***

    a3 = Article.create
      uid: 3
      title: 'Wonderful Article'
      body: 'lorem ipsum...'
      user_id: 3

    a3.isNewRecord() # => false

***

    articles = Article.all()

    someUsersArticles = Article.find
      user_id: 1

    someUsersArticles.length # => 3

    Article.deleteAll
      user_id: 3

# Model Setup

    #
    # Resources/models/article.coffee
    #
    Database = require 'lib/database'

    class Article extends Database

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

