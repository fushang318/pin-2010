module MindmapNoteMethods
  NOTE_REPO_BASE_PATH = '/web/2010/daotu_files/notes'

  # 如果备注版本库不存在，就创建一个
  def create_note_repo_if_unexist
    if !self.note_repo_exist?
      MpGitTool.init_repo(note_repo_path)
    end
  end

  # 删除节点备注
  def destroy_node_note(local_id)
    file_name = "notefile_#{local_id}"
    repo = self.note_repo
    begin
      MpGitTool.delete_file!(repo,self.user,file_name)
    rescue Exception => ex
      p ex # 1月7日部署后，note提交会触发一个bug，先暂时这样fix
    end
  end

  # 增加节点备注
  def update_node_note(local_id,note)
    create_note_repo_if_unexist
    file_name = "notefile_#{local_id}"
    file_content = note
    repo = self.note_repo
    MpGitTool.add_text_content!(repo,self.user,{file_name=>file_content})
  end

  # 所有备注
  def node_notes
    node_notes_hash = Hash.new('')
    self.node_file_notes.each{|name,data|node_notes_hash[name.gsub("notefile_","")] = data}
    node_notes_hash
  end

  def node_file_notes
    repo = self.note_repo
    commit = repo.commit("master")
    contents = commit ? commit.tree.contents : []
    blobs = contents.select do |item|
      item.instance_of?(Grit::Blob) && item.name != ".git" && item.name.match("notefile_")
    end
    node_file_notes_hash = {}
    blobs.each{|blob|node_file_notes_hash[blob.name] = blob.data}
    node_file_notes_hash
  rescue
    {}
  end

  # 备注对应的版本库是否存在
  def note_repo
    create_note_repo_if_unexist
    Grit::Repo.new(note_repo_path)
  end

  # 备注的版本库路径
  def note_repo_path
    raise "mindmap id is null" if self.id.blank?
    
    asset_id = (self.id / 1000).to_s
    File.join(NOTE_REPO_BASE_PATH,asset_id,self.id.to_s)
  end

  def note_repo_exist?
    !self.id.blank? && File.exist?(note_repo_path)
  end

end