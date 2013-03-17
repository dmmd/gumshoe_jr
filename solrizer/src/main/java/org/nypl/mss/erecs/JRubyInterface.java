package org.nypl.mss.erecs;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.HttpSolrServer;

public class JRubyInterface {
    private final File filedir;
    private final File index;
    private final String solrURL;
    private HttpSolrServer HttpSolrServer;
    private HttpSolrServer solr;
    
    public JRubyInterface(String filedir, String index, String solrUrl) throws SolrServerException, IOException{
        System.out.println("eri solrizer v.0.0.1");
        this.filedir = new File(filedir);
        this.index = new File(index);
        this.solrURL = solrUrl;
        testArgs();
        process();
        
    }

    private void testArgs() throws SolrServerException, IOException {
        
        if(!index.exists()){
            System.out.println(index.getAbsoluteFile());
            System.err.println("Index file can not be read");
            System.exit(1);
        }
        
        if(!filedir.exists()){
            System.out.println(index.getAbsoluteFile());
            System.err.println("Files directory can not be read");
            System.exit(1);
        }
        
        if(!setupSolr()){
            System.err.println("Cannot connect to SolrServer");
            System.exit(1);
        }
    }

    private Boolean setupSolr() throws SolrServerException, IOException {
        solr = HttpSolrServer = new HttpSolrServer(solrURL);
        if(solr.ping().getResponse() != null){
            return true;
        } else { return false;}
    }

    private void process() throws FileNotFoundException, IOException, SolrServerException {
        TSV_Parser tsv = new TSV_Parser(filedir, index, solr);
    }
}
