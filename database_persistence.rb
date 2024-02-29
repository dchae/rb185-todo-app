require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'todos')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info("#{statement}: #{params}")
    @db.exec_params(statement, params)
  end

  def find_list(id)
    # @session[:lists].find { |list| list[:id] == id }
    sql = 'SELECT * FROM lists WHERE id = $1'
    result = query(sql, id)

    tuple = result.first
    list_id = tuple['id'].to_i
    todos = find_todos_for_list(list_id)
    { id: list_id, name: tuple['name'], todos: todos }
  end

  def all_lists
    sql = 'SELECT * FROM lists'
    result = query(sql)

    result.map do |tuple|
      list_id = tuple['id'].to_i

      todos = find_todos_for_list(list_id)
      { id: list_id, name: tuple['name'], todos: todos }
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
    delete_lists_sql = 'DELETE FROM lists WHERE id = $1'
    delete_todos_sql = 'DELETE FROM todos WHERE list_id = $1'
    query(delete_lists_sql, id)
    query(delete_todos_sql, id)
  end

  def create_new_todo(list_id, text)
    # list = find_list(list_id)
    # todo_id = next_element_id(list[:todos])
    # list[:todos] << { id: todo_id, name: text, completed: false }
  end

  def delete_todo_from_list(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # todo = list[:todos].find { |todo| todo[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def update_list_name(list_id, new_name)
    # list = find_list(list_id)
    # list[:name] = new_name
    sql = 'UPDATE lists SET name = $2 WHERE id = $1'
    query(sql, list_id, new_name)
  end

  def mark_all_todos_completed(list_id)
    # list = find_list(list_id)
    # list[:todos].each { |todo| todo[:completed] = true }
  end

  def add_success_message(msg)
    # @session[:success] = msg
  end

  def add_error_message(error)
    # @session[:error] = error
  end

  private
  def find_todos_for_list(list_id)
    todos_sql = 'SELECT * FROM todos WHERE list_id = $1'
    todos_result = query(todos_sql, list_id)

    todos_result.map do |todo|
      {
        id: todo['id'].to_i,
        name: todo['name'],
        completed: todo['completed'][0] == 't',
      }
    end
  end


end
