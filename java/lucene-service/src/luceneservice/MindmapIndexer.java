package luceneservice;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.LockObtainFailedException;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 * 导图索引
 * @author Administrator
 */
public class MindmapIndexer extends Indexer {

  private Directory indexDir;         // 索引目录
  private ConfigFile cf;

  MindmapIndexer() {
  }

  MindmapIndexer(ConfigFile cf) throws IOException {
    this.cf = cf;
    this.indexDir = FSDirectory.open(new File(cf.getMindmapIndexPath()));
  }

  /**
   * 索引所有的导图
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public int indexAllMindmap() throws ClassNotFoundException, SQLException, IOException {
    writer = new IndexWriter(indexDir, new IKAnalyzer(), isEmpty(), IndexWriter.MaxFieldLength.UNLIMITED);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    Connection connection = getConnection();
    PreparedStatement stat = connection.prepareStatement("select * from mindmaps ;");
    ResultSet set = stat.executeQuery();
    int i = 0;
    while (set.next()) {
      Mindmap mindmap = new Mindmap(set.getString("id"), set.getString("title"), set.getString("content"));
      checkMindmapIndex(mindmap);
      indexMindmapContent(mindmap);
      i++;
    }
    connection.close();
    writer.optimize();
    writer.close();
    return i;
  }

  /**
   * 根据id找到mindmap
   * @param id
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public Mindmap find(int id) throws ClassNotFoundException, SQLException {
    Connection connection = getConnection();
    PreparedStatement stat = connection.prepareStatement("select * from mindmaps where id = ? ;");
    stat.setInt(1, id);
    ResultSet set = stat.executeQuery();
    Mindmap mp = null;
    if (set.next()) {
      mp = new Mindmap(set.getString("id"), set.getString("title"), set.getString("content"));
    }
    connection.close();
    return mp;
  }

  /**
   * 索引单个的导图
   * @return
   * @throws IOException
   */
  public int indexMindmap(int mindmapId) throws IOException, ClassNotFoundException, SQLException {
    writer = new IndexWriter(indexDir, new IKAnalyzer(), isEmpty(), IndexWriter.MaxFieldLength.UNLIMITED);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    Mindmap mindmap = find(mindmapId);
    checkMindmapIndex(mindmap);
    indexMindmapContent(mindmap);
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 把一个导图的内容索引文档 添加到writer对象中
   */
  private void indexMindmapContent(Mindmap mindmap) throws CorruptIndexException, IOException {
    System.out.println("indexing " + mindmap.getTitle());
    Document doc = new Document();
    doc.add(new Field("id", mindmap.getId(), Field.Store.YES, Field.Index.NOT_ANALYZED));
    doc.add(new Field("title", mindmap.getTitle(), Field.Store.YES, Field.Index.ANALYZED));
    doc.add(new Field("content", mindmap.getContent(), Field.Store.YES, Field.Index.ANALYZED, Field.TermVector.WITH_POSITIONS_OFFSETS));
    writer.addDocument(doc);
  }

  /**
   * 检查是否存在索引文档，如果存在删除之
   */
  private void checkMindmapIndex(Mindmap mindmap) throws IOException {
    if (!isEmpty()) {
      System.out.println(new StringBuffer("delete index ").append(mindmap.getId()).append(" ").append(mindmap.getTitle()).toString());
      writer.deleteDocuments(new Term("id", mindmap.getId()));
    }
  }

  /**
   * 返回导图的索引目录是否为空
   * @return
   */
  public boolean isEmpty() throws IOException {
    return indexDir.listAll().length == 0;
  }

  /**
   * 删除单个导图的索引
   * @param mindmapId
   * @return
   * @throws CorruptIndexException
   * @throws LockObtainFailedException
   * @throws IOException
   */
  public int deleteIndex(int mindmapId) throws CorruptIndexException, LockObtainFailedException, IOException {
    writer = new IndexWriter(indexDir, new IKAnalyzer(), false, IndexWriter.MaxFieldLength.UNLIMITED);
    writer.setUseCompoundFile(false);// Setting to turn on usage of a compound file when on.
    writer.deleteDocuments(new Term("id", String.valueOf(mindmapId)));
    int numIndexed = writer.numDocs();
    writer.optimize();
    writer.close();
    return numIndexed;
  }

  /**
   * 返回mysql数据库 链接 的类
   * @return
   * @throws ClassNotFoundException
   * @throws SQLException
   */
  public Connection getConnection() throws ClassNotFoundException, SQLException {
    Class.forName("com.mysql.jdbc.Driver");
    return DriverManager.getConnection(cf.getDatabaseUrl(), cf.getDatabaseUserName(), cf.getDatabasePassword());
  }
  /**
  public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
  Mindmap mindmap = Mindmap.find("8");
  MindmapIndexer mi = new MindmapIndexer("\\\\192.168.1.8\\root\\web\\2010\\lucene\\mindmaps\\index");
  //给单个导图建立索引
  System.out.println(mi.indexMindmap(mindmap));
  //给所有的导图建立索引
  System.out.println(mi.indexAllMindmap());
  }
   */
}