require './init'
require_relative 'post'
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
    rescue PG::Error, NoMethodError => error
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

  def ThreadManager.get_posts(thread, limit, sort, marker,slug_or_id, order)
    if sort == 'flat'
      posts = sql "
                    SELECT
                      *
                    FROM posts as p
                    WHERE p.thread_id = #{thread["id"]}
                    ORDER BY p.created #{order}, p.id #{order}
                    LIMIT #{limit} OFFSET #{marker}
                   "
      res = {}
      res["marker"] = (posts.cmd_tuples + marker.to_i).to_s
      posts_container = []
      posts.each do |post|
        posts_container << Post.to_read_with_thread_slug(post, slug_or_id)
      end
      res["posts"] = posts_container
      return res
    end

    if sort == 'tree'
      posts = sql "
                    SELECT
                      *
                    FROM posts AS p
                    WHERE p.thread_id = #{thread["id"]} AND p.path && ARRAY[p.id::INTEGER]
                    ORDER BY path #{order}, p.id #{order}
                    LIMIT #{limit} OFFSET #{marker}
                  "
      res = {}
      res["marker"] = (posts.cmd_tuples + marker.to_i).to_s
      posts_container = []
      posts.each do |post|
        posts_container << Post.to_read_with_thread_slug(post, slug_or_id)
      end
      res["posts"] = posts_container
      return res
    end

    if sort == 'parent_tree'
      posts = sql_without "
                    WITH sub AS (
                      SELECT *
                      FROM posts
                      WHERE parent is NULL AND thread_id = #{thread["id"]}
                      ORDER BY path #{order}, id #{order}
                      LIMIT #{limit} OFFSET #{marker}
                    )

                    SELECT
                      *
                    FROM posts AS p
                    WHERE p.thread_id = #{thread["id"]} AND p.path && ARRAY[p.id::INTEGER] AND p.path[1] IN (SELECT id FROM sub)
                    ORDER BY path #{order}, p.id #{order};


                  "
      cnt = sql "SELECT count(id) FROM (
                      SELECT *
                      FROM posts
                      WHERE parent IS NULL AND thread_id = #{thread["id"]}
                      ORDER BY path #{order}, id #{order}
                      LIMIT #{limit} OFFSET #{marker}
                    ) AS e;"
      res = {}
      res["marker"] = (cnt[0]["count"].to_i + marker.to_i).to_s
      posts_container = []
      posts.each do |post|
        posts_container << Post.to_read_with_thread_slug(post, slug_or_id)
      end
      res["posts"] = posts_container
      return res
    end
  end

  def ThreadManager.update_thread(thread, json)
    begin
      result = sql_exec_prepare 'update thread', thread["id"], json["message"], json["title"]
      return result[0]
    rescue PG::Error => err
      return nil
    end

  end

end