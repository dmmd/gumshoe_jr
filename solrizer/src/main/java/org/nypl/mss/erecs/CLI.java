package org.nypl.mss.erecs;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.SQLException;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

public class CLI {
    private final String[] args;

    public static void main(String[] args) throws ParseException, ClassNotFoundException, SQLException, FileNotFoundException, IOException{
        CLI cli = new CLI(args);
    }
    private PosixParser parser;
    private CommandLine cmd;
    
    public CLI(String[] args) throws ParseException, ClassNotFoundException, SQLException, FileNotFoundException, IOException {
        this.args = args;
        System.out.println("eri solr load utility");
        getArgs();
        if(cmd.hasOption("f") && cmd.hasOption("i") && cmd.hasOption("i")){
            System.out.println("CONTINUE");
        } else {
            System.err.println("Correct Syntax: java -jar ERI_Solrizer.jar -f [file directory] -i [index file]");
            System.exit(1);
        }
    
   }
    


    private void getArgs() throws ParseException {
        Options options = new Options();
        options.addOption("f", true, "file directory");
        options.addOption("i", true, "index file");
        options.addOption("s", true, "solr server");
        parser = new PosixParser();
        cmd = parser.parse(options, args);
    }
}
