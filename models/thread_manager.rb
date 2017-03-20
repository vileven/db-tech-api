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

  def ThreadManager.get_thread_by_slug(slug)
    thread = sql_exec_prepare 'get thread by slug', slug
    if thread.cmd_tuples == 0
      return nil
    end
    thread[0]
  end

  def ThreadManager.get_thread_by_id(id)
    thread = sql_exec_prepare 'get thread by id', id
    if thread.cmd_tuples == 0
      return nil
    end

    thread[0]
  end

  def ThreadManager.to_int (val)
    begin
      return Integer(val)
    rescue ArgumentError, TypeError => error
      return nil
    end
  end

  def ThreadManager.get_thread_by_id_or_slug(id_or_slug)
    id = ThreadManager.to_int(id_or_slug)
    if id
      thread = sql_exec_prepare 'get thread by id', id
    else
      thread = sql_exec_prepare 'get thread by slug', id_or_slug
    end

    if thread.cmd_tuples == 0
      return nil
    end
    thread[0]
  end

  def ThreadManager.get_thread_all_by_id_or_slug(id_or_slug)
    id = ThreadManager.to_int(id_or_slug)
    if id
      thread = sql_exec_prepare 'get thread by id', id
    else
      thread = sql_exec_prepare 'get thread by slug', id_or_slug
    end

    if thread.cmd_tuples == 0
      return nil
    end
    thread[0]
  end

  def ThreadManager.vote(user, thread, vote)
    p vote
    vote_val = ThreadManager.to_int vote
    if vote_val.nil?
      return false
    end
    begin
      votes = 0
      if vote_val > 0
        vote = "+ 1"
        transaction do |con|
          con.exec "INSERT INTO votes (user_id, thread_id) VALUES (#{user["id"]},#{thread["id"]});"
          votes = con.exec "UPDATE threads SET votes = votes #{vote} WHERE id = #{thread["id"]} RETURNING votes;"
        end
      else
        vote = "- 1"
        transaction do |con|
          con.exec "DELETE FROM votes WHERE user_id = #{user["id"]} AND thread_id = #{thread["id"]}"
          votes = con.exec "UPDATE threads SET votes = votes #{vote} WHERE id = #{thread["id"]} RETURNING votes;"
        end
      end
      p votes[0]
      return votes[0]["votes"]
    rescue PG::Error => error
      # return thread["votes"]
    end

  end

  def ThreadManager.to_read(thread)
    return {
        author: thread["author"],
        created: DateTime.parse(thread["created"]).iso8601(3),
        forum: thread["forum"],
        id: ThreadManager.to_int(thread["id"]),
        message: thread["message"],
        slug: thread["slug"],
        title: thread["title"]
    }
  end

  def ThreadManager.to_read_with_votes(thread)
    p thread
    return {
        author: thread["author"],
        created: DateTime.parse(thread["created"]).iso8601(3),
        forum: thread["forum"],
        id: ThreadManager.to_int(thread["id"]),
        message: thread["message"],
        slug: thread["slug"],
        title: thread["title"],
        votes: ThreadManager.to_int(thread["votes"])
    }
  end

end