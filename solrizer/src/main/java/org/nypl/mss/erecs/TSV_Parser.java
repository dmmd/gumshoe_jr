
package org.nypl.mss.erecs;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.commons.codec.digest.DigestUtils;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrServer;

public class TSV_Parser {

    private final File indexFile;
    private final File fileDir;
    private String cid, cname, series, parentSeries;
    private Pattern serPattern = Pattern.compile("^SERIESINFO");
    private Pattern invPattern = Pattern.compile("^INVENTORY");
    private Map<String, String> seriesMD = new HashMap<String, String>();
    private static HttpSolrServer solr;
    private static TikaTools tt = new TikaTools();
    private Map <String, String> filehash = new HashMap<String, String>();
    
    public TSV_Parser(File fileIn, File indexIn, HttpSolrServer solrIn) throws FileNotFoundException, IOException, SolrServerException {
        
        indexFile = indexIn;
        fileDir = fileIn;
        solr = solrIn;
        
        if(indexFile.exists() && indexFile.isFile() && !indexFile.isHidden() && indexFile.canRead()){
            mapFiles();
            parseIndex();
            solr.commit();
            System.err.println("Records committed");
            solr.optimize();
            System.err.println("Database optimized");
        } else {
            System.exit(1);
        }
    }

    private void parseIndex() throws FileNotFoundException, IOException, SolrServerException {        
        BufferedReader br = new BufferedReader(new FileReader(indexFile));
        String line;
        String status = "NULL";
        while((line = br.readLine()) != null){
            
            Matcher m1 = serPattern.matcher(line);
            Matcher m2 = invPattern.matcher(line);

            if(m1.find()){
                status = "SERIES";
                continue;
            } else if(m2.find()){
                status = "INVENTORY";
                printInfo();
                continue;
            } else {
                if(status.equals("SERIES")){
                    addSeriesInfo(line);
                }   else if(status.equals("INVENTORY")){
                    processFile(line);
                } else {
                    System.out.println("HUH");
                }
            }
        }
    }

    private void addSeriesInfo(String line) {
        String[] pair = line.split("\t");
        seriesMD.put(pair[0], pair[1]);
        if(pair[0].equals("cid")){
            cid = pair[1];
        }
        
        if(pair[0].equals("cname")){
            cname = pair[1];
        }
        
        if(pair[0].equals("series")){
            series = pair[1];
        }
        
        if(pair[0].equals("parentSeries")){
            parentSeries = pair[1];
        }
    }

    private void printInfo() {
        System.out.println("\nProcessing\ncollection id: " + cid
                + "\ncollection name: " + cname
                + "\nseries: " + series
                + "\nparent series: " + parentSeries
                + "\n-------\n"
                );
    }

    private void processFile(String line) throws SolrServerException, IOException {
        FileProcessor fp = new FileProcessor(line, seriesMD, solr, tt, filehash, fileDir);
    }
    
    private void mapFiles() throws FileNotFoundException, IOException {
        for(File file: fileDir.listFiles()){
            if(file.isFile()){
                filehash.put(DigestUtils.md5Hex(new FileInputStream(file)), file.getName());
            }
        }
    }
}