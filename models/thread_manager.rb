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
      # exists_vote = sql_exec_prepare 'vote exists?', user["id"], thread["id"]
      # if exists_vote.cmd_tuples == 0
      #   sql_exec_prepare 'insert vote', user["id"], thread["id"], vote_val
      # else
      #   sql_exec_prepare 'update vote', user["id"], thread["id"], vote_val
      # end
      sql_exec_prepare 'insert vote', user["id"], thread["id"], vote_val
      return true
    rescue PG::Error => error
      return false
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