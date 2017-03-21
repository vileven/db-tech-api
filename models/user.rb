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

  def User.change_user_by_login(login, json)
    user = sql_exec_prepare 'change user by login', login, json["email"], json["fullname"], json["about"]
    if user.cmd_tuples == 0
      return nil
    end

    return user[0]
  end

  def User.get_user_by_login(login)
    user = sql_exec_prepare 'get user by login', login
    if user.cmd_tuples == 0
      return nil
    end
    user[0]
  end

  def User.get_user_by_login_with_id(login)
    user = sql_exec_prepare 'get user by login with id', login
    if user.cmd_tuples == 0
      return nil
    end
    user[0]
  end

  def User.get_user_by_login_or_email(login, email)
    exists_users = sql_exec_prepare 'get user by login or email', login, email
    if exists_users.cmd_tuples == 0
      return nil
    end
    res = []

    exists_users.each do |row|
      res << row
    end
    return res
  end

  def User.valid_changing?(login, json)
    users = sql_exec_prepare 'validate changing on unique email', login, json["email"]
    if users.cmd_tuples == 0
      true
    else
      false
    end
  end

  def User.validates(json)
    true
  end

  def initialize(login, email, name, about)
    @login, @email, @name, @about = login, email, name, about
  end

  def User.get_user_by_id(id)
    sql_exec_prepare 'get user by id', id
  end

  def save

  end
  private

end
