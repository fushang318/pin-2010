class ResqueQueueWorkerManagement
  # 包含的 queue
  Queues = ConfigManager.resque_queues
  # 支持的操作
  Operations = ["start",'stop']
  WORKER_SH_PATH = File.join(ConfigManager.pin_2010_path,"sh/worker_sh")
  
  class << self
    def start?(queue_name)
      check_resque_queue_name(queue_name)
      state(queue_name) == "正常运行"
    end

    def state(queue_name)
      check_resque_queue_name(queue_name)
      pid_file_path = get_pid_file_path_by_queue_name(queue_name)
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def operate(queue_name,operation)
      check_resque_queue_name(queue_name)
      check_operation_param(operation)
      change_dir_to_worker_sh_path{
        `sh resque_queue_worker.sh #{queue_name} #{operation}`
      }
    end

    def log_size(queue_name)
      file_path = find_log_file_path_by_queue_name(queue_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.size(file_path)
    end

    def log_mtime(queue_name)
      file_path = find_log_file_path_by_queue_name(queue_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def log_content(queue_name)
      file_path = find_log_file_path_by_queue_name(queue_name)
      `touch #{file_path}` if !File.exist?(file_path)
      ManagementUtil.log_file_content(file_path)
    end

    def pid_count(queue_name)
      pid_file_path = get_pid_file_path_by_queue_name(queue_name)
      ManagementUtil.get_pid_count_by_pid_file(pid_file_path)
    end
    
    private
    def check_resque_queue_name(queue_name)
      raise "没有 #{queue_name} 这个 queue" unless Queues.include?(queue_name)
    end
    
    def get_pid_file_path_by_queue_name(queue_name)
      "/web/2010/pids/#{queue_name}_worker.pid"
    end

    def check_operation_param(operation)
      raise "没有 #{operation} 这个 operation" unless Operations.include?(operation)
    end

    def change_dir_to_worker_sh_path
      Dir.chdir(WORKER_SH_PATH) do
        yield
      end
    end

    def find_log_file_path_by_queue_name(queue_name)
      check_resque_queue_name(queue_name)
      "/web/2010/logs/#{queue_name}_worker.log"
    end    
  end

end