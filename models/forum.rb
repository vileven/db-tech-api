require './init'

class Forum

  def Forum.create(json, user)
    # posts, slug, threads, title, "user", user_id

    begin
      res = sql_exec_prepare 'create forum without posts and threads', json["slug"], json["title"],
                     user["nickname"] , user["id"]
    rescue PG::Error => error
      p error
      return nil
    end

    return res[0]
  end

  def Forum.get_forum_by_slug(slug)
    forum = sql_exec_prepare 'get forum by slug', slug

    if forum.cmd_tuples == 0
      return nil
    end

    return forum[0]
  end


end