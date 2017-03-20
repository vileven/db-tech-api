require './init'
require 'time'
# require 'date_time'
class ThreadManager
  def ThreadManager.create(forum, user, json)
  #   (author, author_id, created, forum, forum_id, message, title)

    begin
      thread = sql_exec_prepare 'create thread', user["nickname"], user["id"], json["created"], forum["slug"],
                                  forum["id"], json["message"], json["slug"], json["title"]
    rescue PG::Error => error
      return nil
    end
    res = thread[0]
    p res["created"]
    res["created"] = DateTime.parse(res["created"]).iso8601(3)
    res

  end

  def ThreadManager.get_thread_by_id(id)
    thread = sql_exec_prepare 'get thread by id', id
    if thread.cmd_tuples == 0
      return nil
    end

    thread[0]
  end

  def ThreadManager.get_thread_by_id_or_slug(id_or_slug)
    thread = sql_exec_prepare 'get thread by id', id_or_slug.to_i
    if thread.cmd_tuples == 0
      thread = sql_exec_prepare 'get thread by slug', id_or_slug
      if thread.cmd_tuples == 0
        return nil
      end
    end
    p thread
    thread[0]
  end
end