require './init'

class Post
  def Post.create(forum, user, thread, json, current_time)
    #   (author, author_id, created, is_edited, forum, forum_id, message, parent, thread)

    # p json

    post = sql_exec_prepare 'create post', user["nickname"], user["id"],
                            current_time, json["isEdited"],
                            forum["slug"], forum["id"],
                            json["message"], json["parent"],
                            thread["slug"], thread["id"]

    post[0]
  end

  def Post.to_read(post, slug_or_id)
    # th_id = slug_or_id
    # begin
    #   th_id = Integer(slug_or_id)
    # rescue ArgumentError, TypeError => error
    #   th_id = slug_or_id
    # end
    return {
        author: post["author"],
        created: DateTime.parse(post["created"]).iso8601(3),
        forum: post["forum"],
        id: Integer(post["id"]),
        isEdited: (post["is_edited"] == 'f') ? false : true,
        message: post["message"],
        parent: Integer(post["parent"]),
        thread: Integer(post["thread_id"])
    }
  end
end