import interfascia.*;
import processing.serial.*;
PrintWriter output;
boolean datalogging = true;
boolean g_enableFilter = true;

GUIController gc;
IFTextField vRange;
IFTextField iRange;
IFButton submit;

//IFLabel vRangeLabel;
//IFLabel iRangeLabel;

int _vRange = 5;
int _iRange = 5;

int winW = 820;   // Total Window Width
int winH = 525;   // Total Window Height
int graph_X1 = 20; // Voltage Draw Area Left X Coord
int graph_Y1 = 20; // Voltage Draw Area Top Y Coord
int graph_X2 = 800; // Voltage Draw Area Right X Coord
int graph_Y2 = 400; // Voltage Draw Area Bottom Y Coord

cDataArray vElbow = new cDataArray(1500);
cDataArray iElbow = new cDataArray(1500);
cDataArray vShoulder = new cDataArray(1500);
cDataArray iShoulder = new cDataArray(1500);
cDataArray DataLog = new cDataArray(1500);
cDataArray elbowAngle = new cDataArray(1500);
cDataArray shoulderAngle = new cDataArray(1500);
cDataArray pwmElbow = new cDataArray(1500);
cDataArray pwmShoulder = new cDataArray(1500);

boolean logging = true;

// declare an instance of the serial class:
Serial dataPort;

void setup() 
{
  background(#949DA0);
  drawKey();
  
  gc = new GUIController(this);
  vRange = new IFTextField("Text Field", graph_X1+300, graph_Y2+5, 100);
  vRange.setValue(String.valueOf(_vRange));
  
  iRange = new IFTextField("Text Field", graph_X1+300, graph_Y2+35, 100);
  iRange.setValue(String.valueOf(_iRange));
  
  submit = new IFButton("Submit", 300, 470, 40, 17);
  submit.addActionListener(this);
  vRange.addActionListener(this);
  iRange.addActionListener(this);
  
  gc.add(vRange);
  gc.add(iRange);
  gc.add(submit);
  
  // List all the available serial ports:
  //println(Serial.list());
  
  dataPort = new Serial(this, Serial.list()[1], 115200);
  output = createWriter("/Users/Chris/Documents/Processing/battery_monitor/data.txt");
  output.println("Time (ms), Elbow Angle, Shoulder Angle, PWM Elbow, PWM Shoulder, Elbow Current (A), Elbow Voltage (V), Shoulder Current (A), Shoulder Voltage (V)");
  dataPort.bufferUntil('\n');
}

void draw() 
{
  // Draw graph outline
  strokeWeight(1);
  fill(#000000);
  drawOutline();
  

  // graph the data
  drawGraph(vElbow, iElbow, vShoulder, iShoulder);
  
  // Press a key to stop saving the data and close log file (real-time graphing continues... stop?)
  
  if (logging == false) 
  {
    datalogging = false;
    //dataPort.clear();
    //dataPort.stop();
    
    // Prints non-averaged values
    //
    output.println(DataLog.getCurSize());
    for (int i = 0; i < DataLog.getCurSize() - 1; i++)
    {
      output.println( DataLog.getVal(i) + "," + elbowAngle.getVal(i) + "," + shoulderAngle.getVal(i) + "," + pwmElbow.getVal(i) 
      + "," + pwmShoulder.getVal(i) + "," + iElbow.getVal(i) + "," + vElbow.getVal(i) + "," + iShoulder.getVal(i) + "," + vShoulder.getVal(i) ); 
    }
    
    
    output.flush(); // Write the remaining data
    output.close(); // Finish the file
    drawKey();
  }        
}  

void keyPressed() 
{
  if (key == TAB) 
  {
    logging = false;
  }  
}
  
// Read the sensor data
//
void serialEvent(Serial dataPort) 
{ 
  
  // read the serial buffer:
  String dataString = dataPort.readStringUntil('\n');
  
  //
  // DUMB HACK NEEDS TO BE CHANGED BELOW
  //
  if (dataString != null && dataString.length() > 40) 
  {

     dataString = trim(dataString);
     float sensorData[] = float( split(dataString, ',') );
     
       //println("voltage: " + sensorData[0] + " V");
       //println("current: " + sensorData[1] + " mA");      
        // Add sensor array data to corresponding data array objects
        DataLog.addVal( sensorData[0] );
        elbowAngle.addVal( sensorData[1] ); 
        shoulderAngle.addVal( sensorData[2] ); 
        pwmElbow.addVal( sensorData[3] ); 
        pwmShoulder.addVal( sensorData[4] );  
        iElbow.addVal( sensorData[5] );
        vElbow.addVal( sensorData[6] );
        iShoulder.addVal( sensorData[7] );
        vShoulder.addVal( sensorData[8] );

  }    
} 

/////////////////////////////////////
//                                 //
//                                 //
//      Additional Functions       //
//                                 //
//                                 //
/////////////////////////////////////

void logData(float v, float i, int aCount)
{  
  output.println( millis() + "," + v + "," + i );
} 

void drawKey()
{
    // Draw graph key
    size(winW, winH, P2D);
    fill(0, 0, 0);
    
    if (datalogging)
    {
      text("Data logging ENABLED... Press TAB to finish datalogging", graph_X1 + 450, graph_Y2 + 20);
    }
    
    else
    {
      background(#949DA0);
      text("Data logging COMPLETE...", graph_X1 + 450, graph_Y2 + 20);      
    }
    
    text("Elbow Voltage", graph_X1, graph_Y2 + 20);
    text("Elbow Current", graph_X1, graph_Y2 + 50);
    text("Shoulder Voltage", graph_X1, graph_Y2 + 80);
    text("Shoulder Current", graph_X1, graph_Y2 + 110);
    
    text("Voltage Range (V)", graph_X1+190, graph_Y2 + 20);
    text("Current Range (A)", graph_X1+190, graph_Y2 + 50);
    //text("20", (graph_X1-18), (graph_Y1+5) );
    //text("10", (graph_X1-18), ((graph_Y2 - graph_Y1)/2)+20 );
    //text("0", (graph_X1-18), (graph_Y2+5) );
    
    
    strokeWeight(2);
    stroke(255,0,0); // Elbow Voltage Color (originally red)
    line(graph_X1 + 120, graph_Y2 + 16, 200, graph_Y2 + 16); // Draw Voltage Key Line
    stroke(250,250,70); // Elbow Current Color (yellow)   
    line(graph_X1 + 120, graph_Y2 + 46, 200, graph_Y2 + 46); // Draw Current Key Line
    
    stroke(70,70,250); // Shoulder Voltage Color (originally red)
    line(graph_X1 + 120, graph_Y2 + 76, 200, graph_Y2 + 76); // Draw Voltage Key Line
    stroke(100,235,10); // Shoulder Current Color (orange)  
    line(graph_X1 + 120, graph_Y2 + 106, 200, graph_Y2 + 106); // Draw Current Key Line
}

void drawOutline()
{
  stroke(0, 0, 0);
  rectMode(CORNERS);
  rect(graph_X1, graph_Y1, graph_X2, graph_Y2);
}  

// manages data array(s) for graphing.
//
class cDataArray
{
  float[] m_data;
  int m_maxSize;
  int m_curSize;
  int CurrIndex; // keeps track of the index of the oldest element in the array
  
  cDataArray(int maxSize)
  {
    m_maxSize = maxSize;
    m_data = new float[maxSize];
  }
  
  void addVal(float val)
  {
    
    if (g_enableFilter && (m_curSize == m_maxSize)) { // array is full
        
        if (( CurrIndex+1) == m_maxSize) { // array is full, oldest element is at end of array, so add new element at end and reset index to beginning of array
          m_data[CurrIndex] = val;
          CurrIndex = 0; 
        }
        
        else { // array is full, oldest element is not at end of array, add new element, increment index
          m_data[CurrIndex] = val;
          CurrIndex++;
        }
        
      }
    
    else { // array is not full, fill that motherfucker up
      m_data[m_curSize] = val; 
      m_curSize++;
    }
    
  }
  
  float getVal(int index)
  {
    return m_data[index];
  }
  
  int getCurrIndex()
  {
    return CurrIndex;
  }
  
  int getCurSize()
  {
    return m_curSize;
  }
  
  int getMaxSize()
  {
    return m_maxSize;
  }
}



void drawGraph(cDataArray vElbow, cDataArray iElbow, cDataArray vShoulder, cDataArray iShoulder) 
{
    // Draw actual graph data here
    //
    // NOTE: using size of first parameter is technically correct, but this is dumb... find a more elegant solution
    for (int j = 0; j < vElbow.getCurSize()-1; j++) 
    {  
      float map_ElbowVolt = map(vElbow.getVal(j), 0 , _vRange , graph_Y1, graph_Y2); // present mapped elbow voltage
      float map_ElbowCurr = map(iElbow.getVal(j), -5, _iRange, graph_Y1, graph_Y2); // present mapped elbow current
      float map_ShoulderVolt = map(vShoulder.getVal(j), 0 , _vRange , graph_Y1, graph_Y2); // present mapped shoulder voltage
      float map_ShoulderCurr = map(iShoulder.getVal(j), -5, _iRange, graph_Y1, graph_Y2); // present mapped shoulder current
      
      float next_map_ElbowVolt = map(vElbow.getVal(j+1), 0 , _vRange, graph_Y1, graph_Y2); // next-in-array mapped elbow voltage (for smooth line drawing between points)
      float next_map_ElbowCurr = map(iElbow.getVal(j+1), -5, _iRange, graph_Y1, graph_Y2); // next-in-array mapped elbow current (for smooth line drawing between points)
      float next_map_ShoulderVolt = map(vShoulder.getVal(j+1), 0 , _vRange, graph_Y1, graph_Y2); // next-in-array mapped elbow voltage (for smooth line drawing between points)
      float next_map_ShoulderCurr = map(iShoulder.getVal(j+1), -5, _iRange, graph_Y1, graph_Y2); // next-in-array mapped elbow current (for smooth line drawing between points) 
        
      // NOTE: again, x coordinates are the same for voltage, current, and temp, so this is fine for now, but I should probably clean this up
      float x_pos = map( j, 0, vElbow.getMaxSize(), graph_X1+1, graph_X2-1 );
  

      strokeWeight(1);
      stroke(255,0,0); // Elbow Voltage, Red
      line(x_pos,  graph_Y2 - map_ElbowVolt, x_pos+1, graph_Y2 - next_map_ElbowVolt );

      stroke(250,250,70); // Elbow Current, Yellow
      line(x_pos, graph_Y2 - map_ElbowCurr, x_pos+1, graph_Y2 - next_map_ElbowCurr );
      
      stroke(70,70,250); // Shoulder Voltage, Blue
      line(x_pos,  graph_Y2 - map_ShoulderVolt, x_pos+1, graph_Y2 - next_map_ShoulderVolt );

      stroke(100,235,10); // Shoulder Current, Green
      line(x_pos, graph_Y2 - map_ShoulderCurr, x_pos+1, graph_Y2 - next_map_ShoulderCurr );
  }
}

void actionPerformed(GUIEvent e)
{
   if ( (e.getSource() == submit) || (e.getMessage().equals("Completed")) )
  {
     _vRange = int( vRange.getValue() );
     _iRange = int( iRange.getValue() );
  } 
}

    

