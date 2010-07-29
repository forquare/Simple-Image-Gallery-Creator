package sigc;

import java.util.Hashtable;
import sigc.ui.CommandLineInterface;
import sigc.ui.GeneralGUI;

public class Gallery {
	
	private Hashtable<String, String> arguments;
	private Controller controller;
	private CommandLineInterface cli;
	private GeneralGUI gui;
	
	public Gallery(String[] args){
		sortArguments(args);
		
		//If argument for GUI is set, set the GUI
		//gui = GeneralGUI();
		//controller = new Controller(gui);
		//If argument for CLI is set, set the CLI
		cli = new CommandLineInterface();
		controller = new Controller(cli);
	}
	
	private Hashtable<String, String> sortArguments(String[] args){
		int MAX_INT = 19;
		arguments = new Hashtable<String, String>(MAX_INT);
		
		//Do some sorting here
		
		return arguments;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Gallery gallery = new Gallery(args);
	}

}
