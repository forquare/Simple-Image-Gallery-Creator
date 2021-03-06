package sigc.model;

import java.io.FileWriter;
import java.io.File;
import java.io.IOException;
import java.util.Date;

/**
 * Can be used to print errors to a log
 * file called "log.txt".
 * Errors are written on a new line with 
 * the number of seconds from 01/01/1970
 * so that you may calculate the time of the error
 * 
 * @author Ben Lavery
 * @version 05/4/08
 */
public class Logger {
	
	private File file;
	private FileWriter fw;
	
	/**
	 * Constructor sets up the FileWriter.
	 *
	 * @param ID A String containing an error ID.  This is so multiple instances can be created and have different log files.
	 */
	public Logger(String ID){
		file = new File("log_for_" + ID + ".txt");
		try {
			fw = new FileWriter(file);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * Writes an error message to a new line
	 * 
	 * @param err A String containing the error message to print.
	 */
	public void println(String err){
		Date d = new Date();
		try {
			fw.write(d.getTime() + " - ");
			fw.write(err);
			fw.write('\n');
			fw.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}