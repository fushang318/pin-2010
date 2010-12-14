/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package lucene;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.Date;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.search.highlight.Highlighter;
import org.apache.lucene.search.highlight.InvalidTokenOffsetsException;
import org.apache.lucene.search.highlight.QueryScorer;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.wltea.analyzer.lucene.IKQueryParser;
import org.wltea.analyzer.lucene.IKSimilarity;
import org.apache.lucene.search.highlight.SimpleFragmenter;
import org.apache.lucene.search.highlight.SimpleHTMLFormatter;
import org.wltea.analyzer.lucene.IKAnalyzer;

/**
 * 实现搜索
 * @author Administrator
 */
public class NoteSearcher {

  private File indexDir;
  private String q;
  private Integer start;
  private Integer count;

  NoteSearcher(String indexDir, String q) {
    this.indexDir = new File(indexDir);
    this.q = q;
  }

  NoteSearcher(String indexDir, String q, Integer start, Integer count) {
    this.indexDir = new File(indexDir);
    this.q = q;
    this.start = start;
    this.count = count;
  }

  /*
  public static void main(String[] args) throws Exception {
    String indexDir = "\\\\192.168.1.8\\root\\web\\2010\\lucene\\notes\\index";
    String[] qs = {"的"}; // 要查询的单词

    for (String q : qs) {
      Searcher s = new Searcher(indexDir, q);
      System.out.println(s.search());
    }
  }
   *
   */

  public String search() throws IOException, ParseException, Exception {
    if (!indexDir.exists() || !indexDir.isDirectory()) {
      throw new Exception(indexDir + "does not exist or is a directory");
    }
    Directory fsDir = FSDirectory.open(indexDir);
    IndexSearcher is = new IndexSearcher(fsDir);
    is.setSimilarity(new IKSimilarity());
    String[] fileds = {"content", "filename"};
    Query query = IKQueryParser.parseMultiField(fileds, q);
    long startTime = new Date().getTime();
    TopDocs tds = is.search(query, null, 100000);
    ScoreDoc[] total = tds.scoreDocs;
    int totalCount = total.length;
    ScoreDoc[] hits = getScoreDocs(total);
    long endTime = new Date().getTime();
    // 输出统计数据
    System.err.println("Found " + hits.length + " document(s) (in " + (endTime - startTime) + " millisenconds) that matched query '" + q + "'");
    return result(hits, is, (endTime - startTime), query,totalCount);
  }

  // 根据start和count得知是否存在决定搜索结果的数量
  private ScoreDoc[] getScoreDocs(ScoreDoc[] tds) {
    if (start == null || count == null) {
      return tds;
    }
    if(start > tds.length){
      return new ScoreDoc[0];
    }
    int arrayCount = (count > tds.length) ? tds.length-start : count ;
    ScoreDoc[] newRes = new ScoreDoc[arrayCount];
    for (int i = 0, j = start; i < arrayCount; i++, j++) {
      newRes[i] = tds[j];
    }
    return newRes;
  }

  private String result(ScoreDoc[] hits, IndexSearcher is, long time, Query query,int totalCount) throws CorruptIndexException, IOException, InvalidTokenOffsetsException {
    // 输出搜索出的文件名
    String[][] arrays = new String[hits.length][4];
    for (int i = 0; i < hits.length; i++) {
      Document doc = is.doc(hits[i].doc);
      //对要高亮显示的字段格式化，这里只是加红色显示和加粗
      SimpleHTMLFormatter sHtmlF = new SimpleHTMLFormatter("<span class='loud'>", "</span>");
      Highlighter highlighter = new Highlighter(sHtmlF, new QueryScorer(query));
      highlighter.setTextFragmenter(new SimpleFragmenter(100));
      String content = doc.get("content");
      String highStr = "";
      if (content != null) {
        TokenStream tokenStream = new IKAnalyzer().tokenStream("", new StringReader(doc.get("content")));
        highStr = highlighter.getBestFragment(tokenStream, doc.get("content"));
      }
      arrays[i][0] = doc.get("filepath");
      arrays[i][1] = highStr;
      arrays[i][2] = doc.get("commitid");
      arrays[i][3] = String.valueOf(hits[i].score);
      //System.out.println(doc.get("filename"));
    }
    return resultXML(arrays, time,totalCount);
  }

  // 最后以xml形式输出的结果
  private String resultXML(String[][] arrays, long time,int totalCount) {
    StringBuilder sb = new StringBuilder();
    sb.append("<search_results time='").append(time).append("' count='").append(arrays.length).append("' total_count='").append(totalCount).append( "'>");
    for (int i = 0; i < arrays.length; i++) {
      sb.append("<search_result>");
      sb.append("<path>").append(arrays[i][0]).append("</path>");
      sb.append("<highlight> <![CDATA[").append(arrays[i][1]).append("]]> </highlight>");
      sb.append("<commit_id>").append(arrays[i][2]).append("</commit_id>");
      sb.append("<score>").append(arrays[i][3]).append("</score>");
      sb.append("</search_result>");
    }
    sb.append("</search_results>");
    return sb.toString();
  }
}
