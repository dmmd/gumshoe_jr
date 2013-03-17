/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.nypl.mss.erecs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Set;
import java.util.TreeSet;
import opennlp.tools.namefind.NameFinderME;
import opennlp.tools.namefind.TokenNameFinderModel;
import opennlp.tools.tokenize.SimpleTokenizer;
import opennlp.tools.tokenize.Tokenizer;
import opennlp.tools.util.Span;
import org.apache.tika.Tika;
import org.apache.tika.language.ProfilingWriter;

public class TikaTools {
    private final Tika tika;
    private NameFinderME finder;
    
    TikaTools() {
        tika = new Tika();
    }

    
    public String getLanguage(File file) throws IOException{
        BufferedReader br = new BufferedReader(tika.parse(new FileInputStream(file)));
        ProfilingWriter pw = new ProfilingWriter();
        String line;
        while((line = br.readLine()) != null){
            pw.append(line);
        }
        if(pw.getProfile().getCount() > 0)
            return pw.getLanguage().getLanguage();
        else
            return "unknown";
    }
    
    
    public Set<String> getPersons(File file) throws IOException{
        Set<String> nameEnts = new TreeSet<String>();
        finder = new NameFinderME(new TokenNameFinderModel(new FileInputStream(new File("models/en-ner-person.bin"))));
        Tokenizer tokenizer = SimpleTokenizer.INSTANCE;
        String line;
        BufferedReader br = new BufferedReader(tika.parse(new FileInputStream(file)));
        while((line = br.readLine()) != null){
            Span[] tokensSpans = tokenizer.tokenizePos(line);
            String[] tokens = Span.spansToStrings(tokensSpans, line);
            Span[] names = finder.find(tokens);
            for(int i = 0; i < names.length; i++){
                Span startSpan = tokensSpans[names[i].getStart()];
                int nameStart = startSpan.getStart();
                
                Span endSpan = tokensSpans[names[i].getEnd() - 1];
                int nameEnd = endSpan.getEnd();
                
                String name = line.substring(nameStart, nameEnd);
                if(!nameEnts.contains(name)){
                    nameEnts.add(name);
                }
            }
        }
        
        return nameEnts;
    }
    
    
    public Set<String> getLocations(File file) throws IOException{
        Set<String> locEnts = new TreeSet<String>();
        finder = new NameFinderME(new TokenNameFinderModel(new FileInputStream(new File("models/en-ner-location.bin"))));
        Tokenizer tokenizer = SimpleTokenizer.INSTANCE;
        String line;
        BufferedReader br = new BufferedReader(tika.parse(new FileInputStream(file)));
        while((line = br.readLine()) != null){
            Span[] tokensSpans = tokenizer.tokenizePos(line);
            String[] tokens = Span.spansToStrings(tokensSpans, line);
            Span[] names = finder.find(tokens);
            for(int i = 0; i < names.length; i++){
                Span startSpan = tokensSpans[names[i].getStart()];
                int nameStart = startSpan.getStart();
                
                Span endSpan = tokensSpans[names[i].getEnd() - 1];
                int nameEnd = endSpan.getEnd();
                
                String name = line.substring(nameStart, nameEnd);
                if(!locEnts.contains(name)){
                    locEnts.add(name);
                }
            }
        }
        
        return locEnts;
    }
    
    
    public Set<String> getOrganizations(File file) throws IOException{
        Set<String> orgs = new TreeSet<String>();
        finder = new NameFinderME(new TokenNameFinderModel(new FileInputStream(new File("models/en-ner-organization.bin"))));
        Tokenizer tokenizer = SimpleTokenizer.INSTANCE;
        String line;
        BufferedReader br = new BufferedReader(tika.parse(new FileInputStream(file)));
        while((line = br.readLine()) != null){
            Span[] tokensSpans = tokenizer.tokenizePos(line);
            String[] tokens = Span.spansToStrings(tokensSpans, line);
            Span[] names = finder.find(tokens);
            for(int i = 0; i < names.length; i++){
                Span startSpan = tokensSpans[names[i].getStart()];
                int nameStart = startSpan.getStart();
                
                Span endSpan = tokensSpans[names[i].getEnd() - 1];
                int nameEnd = endSpan.getEnd();
                
                String name = line.substring(nameStart, nameEnd);
                if(!orgs.contains(name)){
                    orgs.add(name);
                }
            }
        }
        
        return orgs;
    }
    
    public Tika getTika(){
        return tika;
    }
    /*
    public void getDates() throws IOException{
        finder = new NameFinderME(new TokenNameFinderModel(new FileInputStream(new File("models/en-ner-date.bin"))));
        Tokenizer tokenizer = SimpleTokenizer.INSTANCE;
        String line;
        BufferedReader br = new BufferedReader(tika.parse(new FileInputStream(file)));
        while((line = br.readLine()) != null){
            Span[] tokensSpans = tokenizer.tokenizePos(line);
            String[] tokens = Span.spansToStrings(tokensSpans, line);
            Span[] names = finder.find(tokens);
            for(int i = 0; i < names.length; i++){
                Span startSpan = tokensSpans[names[i].getStart()];
                int nameStart = startSpan.getStart();
                
                Span endSpan = tokensSpans[names[i].getEnd() - 1];
                int nameEnd = endSpan.getEnd();
                
                String name = line.substring(nameStart, nameEnd);
                if(!fm.hasDate(name)){
                    fm.addDate(name);
                }
            }
        }
    }
    
    */
}
