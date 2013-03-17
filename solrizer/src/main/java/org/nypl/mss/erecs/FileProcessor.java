package org.nypl.mss.erecs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrServer;
import org.apache.solr.common.SolrInputDocument;

public class FileProcessor {
    private final String line;
    private final Map<String, String> seriesMD;
    private HttpSolrServer solr;
    private final TikaTools tt;
    private SolrInputDocument document;
    private Map <String, String> filehash;
    private String origName;
    private String accessName;
    private final File fileDir;
    
    FileProcessor(String line, Map<String, String> seriesMD, HttpSolrServer solr, TikaTools tt, Map <String, String> filehash, File fileDir) throws SolrServerException, IOException {
        this.line = line;
        this.seriesMD = seriesMD;
        this.solr = solr;
        this.tt = tt;
        this.filehash = new HashMap(filehash);
        this.fileDir = fileDir;
        process();
    }

    private void process() throws SolrServerException, IOException {

        try{
        String[] fields = line.split("\t");
        document = new SolrInputDocument();
        document.addField("id", new StringBuilder().append(seriesMD.get("cid")).append(".").append(fields[0].toString()));
        document.addField("cid", seriesMD.get("cid"));
        document.addField("cName", seriesMD.get("cname"));
        document.addField("series", seriesMD.get("series"));
        document.addField("parentseries", seriesMD.get("parentSeries"));
        getFilename(fields[1], fields[6]);
        document.addField("filename", origName);
        document.addField("accessname", accessName);
        
        document.addField("path", fields[2]);
        document.addField("fType", fields[3]);
        document.addField("fSize", fields[4]);
        document.addField("mDate", getModDate(fields[5]));
        document.addField("did", getDiskId(fields[2]));
        
        processFile(accessName);
        
        //System.out.println(document);
        solr.add(document);
        } catch (Exception e){
            System.err.println(e);
        }
        
        
    }
    
    private Date getModDate(String field){
        Calendar cal = new GregorianCalendar();
        
        Pattern p = Pattern.compile("\\(.*\\)$");
        Matcher m = p.matcher(field);
        if(m.find()){
            String[] date = m.group().split(" ")[0].substring(1).split("-");
            String[] time = m.group().split(" ")[1].substring(1).split(":");
            cal.set(
                Integer.parseInt(date[0]), Integer.parseInt(date[1]) - 1, Integer.parseInt(date[2]),
                Integer.parseInt(time[0]), Integer.parseInt(time[1]), Integer.parseInt(time[2])   
            );
            return new Date(cal.getTimeInMillis());
        } else {
            return null;
        }
    }

    private void processFile(String filename) throws IOException {
        File file = new File(fileDir.getAbsolutePath() 
                + File.separator + "access"
                + File.separator + filename + ".docx"); 
        if(file.exists()){
            System.out.println("processing: " + file.getName());
            
            //process language
            document.addField("language", tt.getLanguage(file));
            
            //process names
            Set<String> names = new TreeSet<String>(tt.getPersons(file));
            for(String name: names){
                document.addField("names", name);
            }
            
            //process locs
            Set<String> locs = new TreeSet<String>(tt.getLocations(file));
            for(String loc: locs){
                document.addField("locs", loc);
            }
            
            //process orgs
            Set<String> orgs = new TreeSet<String>(tt.getOrganizations(file));
            for(String org: orgs){
                document.addField("orgs", org);
            }
            
            //process text
            BufferedReader br = new BufferedReader(tt.getTika().parse(new FileInputStream(file)));
            String tline;
            StringBuilder sb = new StringBuilder("");
        
            while((tline = br.readLine()) != null){
                sb.append(tline);
            }
        
            document.addField("text", sb.toString());

        } else {
            System.err.println("Cannot locate file " + file.getAbsolutePath());
        }
        
    }

    private Object getDiskId(String path) {
        Pattern diskId = Pattern.compile("^M\\d{4,5}-\\d{4}");
        Matcher m = diskId.matcher(path);
        m.find();
        return m.group();
    }

    

    private void getFilename(String filename, String md5) {
        //System.out.println(filehash.containsKey(md5.toLowerCase()));
        origName = filename;
        accessName = filehash.get(md5.toLowerCase()).toString();
    }
}
