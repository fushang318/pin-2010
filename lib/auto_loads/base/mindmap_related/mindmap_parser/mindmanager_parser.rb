class MindmanagerParser < MapFileParser

  # 导入mindmanager格式的导图文件
  def self.import(mindmap,file_form_param)
    mindmap.struct = self.struct_of_import(file_form_param)
    mindmap.save
  end

  def self.struct_of_import(file_form_param)
   
    unzip_dir = "#{Dir::tmpdir}/mindmap_uploadtemp/#{UUIDTools::UUID.random_create.to_s}"

    path="#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}"
    File.open(path,"wb") do |file|
      file.write(file_form_param.read)
    end

    File.open(path,"r") do |file|
      Zip::ZipFile::open(file.path) {|zf|
        zf.each {|e|
          fpath = File.join(unzip_dir, e.name)
          FileUtils.mkdir_p(File.dirname(fpath))
          zf.extract(e,fpath)
        }
      }
    end
    struct = xslt_transform("#{unzip_dir}/Document.xml",MapFileParser.xslt_file_path("mindmanager_to_mindpin.xslt"))
    struct = process_note_id_to_randstr(struct)

    File.delete(path)
    FileUtils.rmtree(unzip_dir)

    struct
  end

  # 导出mindmanager格式的导图文件
  def self.export(mindmap)
    # 存放Document.xml文件的路径
    path="#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}/"
    FileUtils.mkdir(path)
    file_name = "#{path}Document.xml"
    # 创建并解析document.xml
    create_and_parse_document(mindmap,file_name)
    # zip打包，并且将zip文件改名为mmap
    zip_dir = pack_to_zip(mindmap,file_name)
    File.delete(file_name)
    FileUtils.rm_r(path)
    return zip_dir
  end

  # 创建并解析document.xml
  def self.create_and_parse_document(mindmap,file_name)
    File.open(file_name,"wb") do |file|
      file.write(mindmap.struct)
    end
    # 读取xslt解析的xml内容
    mmap_xml = xslt_transform("#{file_name}",MapFileParser.xslt_file_path("mindpin_to_mindmanager.xslt"))
    xml_content = Nokogiri::XML(mmap_xml)
    # 根据node的id得到node的备注，然后添加到document.xml中
    add_remarks_to_element(mindmap,xml_content)
    # 用Nokogiri解析xml文件，将xml文件中的OId全部换成独立的
    xml_content.css('[OId]').each do |element|
      bytes = UUIDTools::UUID.random_create.raw
      element.attribute('OId').value = Base64.encode64(bytes).gsub("\n","")
    end
    # 将节点标题中的\\n都转化成\n
    xml_content.css('[PlainText]').each do |element|
      element.attribute("PlainText").value = element.attribute("PlainText").value.gsub(/\\./){|m| eval '"'+m+'"'}
    end
    # 将解析后正确的xml文件写入Document.xml中
    File.open(file_name,"w") do |file|
      file.write(xml_content.to_s.gsub("<ap:SubTopics/>",""))
    end
  end

  # 查找element的所对应的备注，并添加到document.xml中去
  def self.add_remarks_to_element(mindmap,xml_content)

    node_note_hash = mindmap.node_notes

    MindmapDocument.new(mindmap).nodes.each do |node|
      node_id = node.id
      note = node_note_hash[node_id]
      if(!note.blank?)
        xml_content.css("[OId='#{node_id}']").each do |n|
          notes_group = Nokogiri::XML::Node.new('NotesGroup',xml_content)
          notes_xhtml_data = Nokogiri::XML::Node.new('NotesXhtmlData',xml_content)
          notes_xhtml_data['Dirty'] = "0000000000000001"
          notes_xhtml_data['PreviewPlainText'] = note
          html_node = Nokogiri::XML::Node.new('html',xml_content)
          html_node['xmlns'] = "http://www.w3.org/1999/xhtml"
          html_node.inner_html = note
          html_node.default_namespace=("http://www.w3.org/1999/xhtml")
          notes_xhtml_data.add_child(html_node)
          notes_group.add_child(notes_xhtml_data)
          n.add_child(notes_group)
        end
      end
    end
  end
  
  # 将需要的东西打包到mmap文件中
  def self.pack_to_zip(mindmap,file_name)
    zip_dir = "#{Dir::tmpdir}/#{mindmap.title}.mmap"
    FileUtils.rm(zip_dir) if File.exist?(zip_dir)
    Zip::ZipFile.open zip_dir, Zip::ZipFile::CREATE do |zip|
      zip.add("Document.xml", file_name)
      zip.add("bin", self.mmap_src_file_path("bin"))
      zip.add("bin/B7E49899-8FA5-4C17-801C-3A2E2A90CF7B.bin",self.mmap_src_file_path("bin/B7E49899-8FA5-4C17-801C-3A2E2A90CF7B.bin"))
      zip.add("xsd",self.mmap_src_file_path("xsd"))
      zip.add("xsd/MindManagerApplication.xsd", self.mmap_src_file_path("xsd/MindManagerApplication.xsd"))
      zip.add("xsd/MindManagerCore.xsd",self.mmap_src_file_path("xsd/MindManagerCore.xsd"))
      zip.add("xsd/MindManagerDelta.xsd", self.mmap_src_file_path("xsd/MindManagerDelta.xsd"))
      zip.add("xsd/MindManagerPrimitive.xsd",self.mmap_src_file_path("xsd/MindManagerPrimitive.xsd"))
    end
    return zip_dir
  end

  def self.mmap_src_file_path(path)
    File.join(self.depend_file_path,"mmap_src_file",path)
  end
end
