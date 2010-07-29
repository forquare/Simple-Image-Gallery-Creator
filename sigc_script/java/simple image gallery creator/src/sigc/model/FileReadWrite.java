package sigc.model;

import java.io.*;
import java.util.Vector;

/**
 * Gets classes from a defined file.
 * Useful if you have a list of classes, such as 
 * the Java Class Library.
 * 
 * @author Ben Lavery
 * @version 16/4/08
 */
public class FileReadWrite {

	private FileReader fread;
	private BufferedReader buf;
	private Logger log = new Logger("FileReadWrite");
	private File file;
	private FileWriter fw;
	
	/**
	 * Reads in, line by line, the values from a file into
	 * a Vector.
	 * 
	 * @return An array of String containing all of the values from the file.
	 */
	public Vector<String> read(String path){
		file = new File(path);
		try{
			fread = new FileReader(file);
			buf = new BufferedReader(fread);
		}catch(FileNotFoundException e){
			log.println("File not found");
		}catch(NullPointerException e){
			log.println("Null Pointer...");
		}
		
		
		String temp;
		Vector<String> working = new Vector<String>();
		
		while(true){
			try {
				temp = buf.readLine();
				
				if(temp == null){
					break;
				}else{
					working.add(temp);
				}
			} catch (IOException e) {
				log.println("Error reading file");
			}catch(NullPointerException e){
				log.println("Null Pointer in file reading...");
			}
		}
		
		return working;
	}
	
	public void writer(Vector<String> toWrite, String path){
		file = new File(path);
		try {
			fw = new FileWriter(file);
		} catch (IOException e) {
			log.println("File not found");
		}
		
		for(int i = 0; i < toWrite.size(); i++){
			try {
				fw.write(toWrite.get(i));
				fw.write('\n');
				fw.flush();
			} catch (IOException e) {
				log.println("Error writing file");
			}
		}
	}
}