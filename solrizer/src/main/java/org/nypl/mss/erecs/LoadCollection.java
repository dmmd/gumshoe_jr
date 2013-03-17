/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.nypl.mss.erecs;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.apache.solr.client.solrj.SolrServerException;

public class LoadCollection {
    public static void main(String[] args) throws FileNotFoundException, IOException, SolrServerException{
        System.out.println("FTK Solrizer 0.0.1");
        File indexes = new File("indexes");
        for(File index : indexes.listFiles()){
            //TSV_Parser tsv = new TSV_Parser(index);
        }
    }
    
}
