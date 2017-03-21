require './init'
require 'time'

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

  def Forum.get_forum_by_slug_with_id(slug)
    forum = sql_exec_prepare 'get forum by slug with id', slug

    if forum.cmd_tuples == 0
      return nil
    end

    forum[0]
  end

  def Forum.get_forum_by_id(id)
    forum = sql_exec_prepare 'get forum by id', id

    if forum.cmd_tuples == 0
      return nil
    end

    forum[0]
  end

  def Forum.get_forum_by_slug(slug)
    forum = sql_exec_prepare 'get forum by slug', slug

    if forum.cmd_tuples == 0
      return nil
    end

    return forum[0]
  end

  def Forum.get_forum_by_thread_id(thread_id)
    forum = sql_exec_prepare 'get forum by thread id', thread_id
    if forum.cmd_tuples == 0
      return nil
    end

    return forum[0]
  end

  def Forum.to_read(forum)
    return {
      posts: forum["posts"].to_i,
      slug: forum["slug"],
      threads: forum["threads"].to_i,
      title: forum["title"],
      user: forum["user"]
    }
  end


  def Forum.get_threads(slug, limit, date, sort)

    dates = ''

    if sort.nil? || sort == 'false'
      sortion = 'ASC'
    else
      sortion = 'DESC'
    end

    if date
      date = DateTime.parse(date).iso8601(3)
      if sortion == 'DESC'
        dates = "AND t.created <= timestamp '#{date}'"
      else
        dates = "AND t.created >= timestamp '#{date}'"
      end
    end

    unless limit || limit > 0
      limit = 100
    end


    threads = sql "
    SELECT
      t.author,
      t.created,
      t.forum,
      t.id,
      t.message,
      t.slug,
      t.title
    FROM threads AS t
    JOIN forums AS f ON t.forum_id = f.id #{dates}
    WHERE LOWER(f.slug) = LOWER('#{slug}')
    ORDER BY t.created #{sortion}
    LIMIT #{limit};
    "
    res = []

    threads.each do |row|
      row["created"] = DateTime.parse(row["created"]).iso8601(3)
      row["id"] = Integer(row["id"])
      res << row
    end
    res
  end

  def Forum.get_users(forum, limit, since, sortion)
    if sortion == "ASC"
      sort = " > LOWER($2)"
    else
      sort = " < LOWER($2)"
    end
    users = sql"
                  WITH sub AS (
                    SELECT
                      u.about,
                      u.email,
                      u.fullname,
                      u.nickname
                    FROM
                      users AS u
                      JOIN posts AS p ON u.id = p.author_id AND p.forum_id = $1
                    UNION
                    SELECT
                      u.about,
                      u.email,
                      u.fullname,
                      u.nickname
                    FROM
                      users AS u
                      JOIN threads AS t ON u.id = t.author_id AND t.forum_id = $1
                  )
                  SELECT
                    about, email, fullname, nickname
                  FROM sub
                  WHERE LOWER(nickname) #{sort}
                  ORDER BY lower(sub.nickname) #{sortion}
                  LIMIT #{limit};
              ",
               forum["id"], since
    res = []
    users.each do |user|
      res << user
    end

    res
  end

end