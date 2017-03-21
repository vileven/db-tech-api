require './init'


class StatusService

  def StatusService.get_info_db
    info = sql_exec_prepare 'get db info'
    res = info[0]
    res["forum"] = res["forum"].to_i
    res["post"] = res["post"].to_i
    res["thread"] = res["thread"].to_i
    res["user"] = res["user"].to_i
    res
  end

  def StatusService.restart_db
    # system("bundle exec rake db:migrate[0]")
    # system("bundle exec rake db:migrate")
    %x{rake db:migrate[0]}
    %x{rake db:migrate}
  end

  def StatusService.drop
    sql "DROP TABLE users;"
    sql "DROP TABLE forums;"
    sql "DROP TABLE threads;"
  end
end