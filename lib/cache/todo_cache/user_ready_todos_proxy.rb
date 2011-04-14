class UserReadyTodosProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_ready_todos"
  end

  def xxxs_ids_db
    @user.ready_todos_db.map{|todo|todo.id}
  end
end
