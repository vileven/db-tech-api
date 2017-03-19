require './init'
class User
  attr :id, :login, :email, :name, :about

  def User.create(json, login)
    if User.validates json
      user = {
          nickname: login,
          email: json["email"],
          fullname: json["fullname"],
          about: json["about"]
      }
      sql_exec_prepare 'create user', user[:nickname], user[:fullname], user[:email], user[:about]

      # sql "INSERT INTO \"User\" (login, name, email, about) VALUES
      #              ('#{login}', '#{json["fullname"]}', '#{json["email"]}', '#{json["about"]}');"

      return user
    end
  end

  def User.exists?(login, email)

    exists_users = sql_exec_prepare 'user exists?', login, email
    if exists_users.cmd_tuples == 0
      return nil
    end
    res = []

    exists_users.each do |row|
      row.delete "id"
      res << row
    end
    return res
  end

  def User.validates(json)
    true
  end

  def initialize(login, email, name, about)
    @login, @email, @name, @about = login, email, name, about
  end

  def save

  end
  private

end
