
module DB
  Config = {
      'development' => {
          'host'   => 'localhost',
          'dbname' => 'testdb'
      },
      'test'        => { },
      # note that 'production' will be overridden by
      # ENV['DATABASE_URL'] in, e.g. Heroku
      'production'  => { }
  }
end