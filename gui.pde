void keyPressed() 
  {
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key=='-') filmingJPG=!filmingJPG;
  if(key=='?') scribeText=!scribeText;
  if(key=='i') {reinitialize(); tc=predict();}
  if(key=='p') tc=predict();
  if(key=='.') advancingToNextFrame=true;
  if(key=='x') clash(); tc=predict();
  if(key=='a') {animating=!animating; if(animating) advancingToNextFrame=true;}
  if(key=='<') {n=max(1,n/2); reinitialize(); }
  if(key=='>') {n*=2; reinitialize(); tc=predict();}
  if(key=='2') {C= P(0,0,0);   z=0; flat=true;  F = P(0,0,0); Gravity=V(0,0.1,0); }
  if(key=='3') {C= P(0,0,rc);  z=1; flat=false; F = P(C);     Gravity=V(0,0,-0.1); reinitialize();}
  if(key=='V') showVelocities=!showVelocities;
  if(key=='C') changingColors=!changingColors;
  if(key=='G') gravity=!gravity;
  if(key=='_') showFloor=!showFloor;
  change=true;   // to save a frame for the movie when user pressed a key 
  }

void mouseWheel(MouseEvent event) 
  {
  dz -= event.getAmount(); 
  change=true;
  }

void mousePressed() 
  {
  change=true;
  }
  
void mouseMoved() 
  {
  //if (!keyPressed) 
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='`') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  //if (keyPressed && key=='.') t+=(float)(mouseX-pmouseX)/width; // change time
  //if (keyPressed && key=='v') {m+=10.*(float)(mouseX-pmouseX)/width; reset();} // change time
  if (keyPressed && key=='m') {scaleVelocties(1.+5.*(mouseX-pmouseX)/width); } // change time
  if (keyPressed && key=='s') {s*=(1.+5.*(mouseX-pmouseX)/width); } // change time
  if (keyPressed && key=='r') r+=100.*(float)(mouseX-pmouseX)/width; // change time
  change=true;
  }
   
void mouseDragged() 
  {
  if (keyPressed && key=='f')  // move focus point on plane
    {
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F')  // move focus point vertically
    {
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  change=true;
  }  

// **** Header, footer, help text on canvas
void displayHeader()  // Displays title and authors face on screen
    {
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter()  // Displays help text at the bottom
    {
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="CS3451-2020-P5: Collision", name ="Kaushi CHANDRARATNA", // *************************   STUDENT: PUT YOUR NAMES HERE !!!
       menu="?:help, !:picture, ~:(start/stop)filming, space:rotate, `/wheel:closer, f*/F*:move focus, _:floor, 2/3:2D/3D",
       guide="i:reset, a:animate, G:gravity, </>:n, m*:speed, r*=radius, s*:scaled V, p:predict, a:advance, x:change velocities"; // user's guide
