require './init'

class Post
  def Post.create(forum, user, thread, json)
    #   (author, author_id, created, is_edited, forum, forum_id, message, parent, thread)

    p thread

    post = sql_exec_prepare 'create post', user["nickname"], user["id"],
                            json["created"], json["isEdited"],
                            forum["slug"], forum["id"],
                            json["message"], json["parent"],
                            thread["slug"], thread["id"]

    res = post[0]
    p res
    res["thread"] = Integer(res["thread_id"])
    res["id"] = Integer(res["id"])
    res["isEdited"] = (res["isEdited"] == 'f') ? false : true
    res["created"] = DateTime.parse(res["created"]).iso8601(3)
    [] << res
  end
end