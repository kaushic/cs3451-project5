//******************************************************** CONTAINER
float rc = 600; // radius of container
PNT C = P(0, 0, 000); // container

//******************************************************** BALLS
int maxn = 1024;
int n=1;                 // current number of balls ('<','>')
PNT[] B = new PNT[maxn]; // centers of ball
float r = 60;           // radius of all balls

//******************************************************** VELOCITIES
VCT[] V = new VCT[maxn]; // velocities of balls
boolean showVelocities=true;
float m = 2; // initial speed of balls (magnitude of V[])
float s = 60;  // scaling of arrows when displaying vectors V[]

//******************************************************** FLAT VS 3D
float z=0; // height: when z==0  ball centers stay on to the floor
boolean flat=true; // true when ball centers stay on the floor

//******************************************************** GRAVITY
boolean gravity=true; // toggle to add gravity
VCT Gravity=V(0, 0.1, 0); // gravity vector  for 2D
//******************************************************** ANIMATION CONTROL
boolean animating=false;            // automatic animation mode
boolean advancingToNextFrame=false;  // boolean set by 'a'
float dtf = 1;                  // interframe time-lapse (1/30 sec) is one unit of time
float tc = 0;                      // remainig time to next collision
float tf = dtf;                      // remainig time to next frame
String Event ="";
int ic=-1, jc=-1;                 // IDs of colliders (-1 means not collider)

//******************************************************** COLORING BALLS TO VISUALIZE EVENTS
boolean changingColors=true; // to show which balls will collide
boolean[] X = new boolean[maxn];  // mark balls that interfere with other balls or stick out of the container (for validation) 
boolean[] Y = new boolean[maxn]; //mark balls that stick out

//******************************************************** DECLARE BALLS, VELOCITIES, ATTRIBUTES
void declareAllBalls() 
{
  for (int i=0; i<maxn; i++) {
    B[i]=P();
  }
  for (int i=0; i<maxn; i++) {
    V[i]=V();
  }
  for (int i=0; i<maxn; i++) {
    X[i]=false;
  } // overlapping of escaping balls
}  


//******************************************************** INITIALIZE BALLS AND VELOCITIES
void reinitialize() {// reset B[0]...B[n] to uniformely random sampling of non-overlapping balls and sets random velocities V[i] 

  for (int i=0; i<maxn; i++) {
    X[i]=false;
  }
  int ballsPlaced = 0;
  while (ballsPlaced < n) {
    do {
  float r = sqrt(1-(sq(random(2)-1)));
  float angle = random(1) * 2 * PI;
      //return U(r*cos(angle), r*sin(angle), random(2)-1);
      B[ballsPlaced] = P((r*cos(angle))*rc, (r*sin(angle))*rc, random(rc)*2*z);//(random(rc)*2-rc, random(rc)*2-rc, random(rc)*2*z);
    } while (sticksOut(ballsPlaced));
    boolean interference = false;
    for (int i = 0; i < ballsPlaced; i++) { //check if interferes with any previous balls
      if (interfere(ballsPlaced, i)) {
        interference = true;
      }
    }
    if (!interference) { //keep ball if it doesn't have interference
      ballsPlaced += 1;
    }
  }

  //check();
  //check2();
  for (int i=0; i<n; i++) {
    if (flat) {
      float w = random(TWO_PI); 
      V[i]=V(m*cos(w), m*sin(w), 0);
    } else {
      V[i]=V(m, RandomDirection());
    }
  }
}  

//******************************************************** INTERFERENCE WITH CONTAINER AND COLLISION TESTS
boolean interfere(int i, int j) // balls i & j interfere 
{
  if (d(B[i], B[j]) <= (r+r)) {
    return true;
  }
  return false;
}  

boolean sticksOut(int i) // balls interferes with container 
{
  if (d(B[i], C) >= (rc-r)- r) {
    return true;
  }
  return false;
}  

//******************************************************** UNIFORMELY RANDOM DIRECTIONS IN 3D
VCT RandomDirection() 
{
  //... Fix me to produce uniformly distributed random directions
  float r = sqrt(1-(sq(random(2)-1)));
  float angle = random(1) * 2 * PI;
  return U(r*cos(angle), r*sin(angle), random(2)-1);
}

void scaleVelocties(float pm) {
  for (int i=0; i<n; i++) V[i].mul(pm);
}

void check() // for testing only: sets X[i]=true; X[j]=true; if balls i and j interfere
{
  for (int i = 0; i < n; i++) {
    for (int j = i + 1; j < n; j++) {
      if (interfere(i, j)) {
        X[i] = true;
        X[j] = true;
      } else {
        X[i] = false;
        X[j] = false;
      }
      if (X[i]) {
        println(X[i]);
      } 
      if (X[j]) {
        println(X[j]);
      }
    }
  }
}

void check2() {
  for (int i = 0; i < n; i++) {
    if (sticksOut(i)) {
      X[i] = true;
    } else {
      X[i] = false;
    }
    if (X[i]) {
      //println(X[i]);
    }
  }
}

//******************************************************** DISPLAY ALL COLORED BALLS AND VELOCITIES
void display() // shows balls and velocities and colors colliders
{
  fill(blue); 
  if (showVelocities) for (int i=0; i<n; i++) arrow(B[i], s, V[i], 10);  
  fill(cyan);
  for (int i=0; i<n; i++) 
  {
    if (changingColors) {
      if (i==ic || i==jc) {
        if (jc==-1) fill(magenta); 
        else fill(red);
      } else {
        if (X[i]) fill(dgreen); 
        else fill(cyan);
      } 
      show(B[i], r);
    }
  } 
  fill(orange, 100); 
  for (int i=0; i<n; i++) {
    if (X[i]) show(B[i], r+5);
  }
  fill(color(150, 200, 100, 100)); 
  pushMatrix(); 
  if (flat) {
    scale(1, 1, 0.01);
  }// flat mode squashes the container
  show(C, rc);
  popMatrix();
}  


//******************************************************** ADVANCES ANMATION TO NECT DISPLAY-FRAME 
void advanceToNextFrame() // may involve any number of collisions or bounces along the way
{
  //check2();
  boolean ready = false; // will become true when the next frame will happen before the next collision 

  while (!ready) {
    if (flat && gravity) {
      Gravity=V(0, 0.01, 0);
      for (int i=0; i<n; i++) {
        V[i] = A(V[i], Gravity);
        tc = predict();
      }
    } else if (!flat && gravity) {
      Gravity=V(0, 0, -0.01);
      for (int i=0; i<n; i++) {
        V[i] = A(V[i], Gravity);
        tc = predict();
      }
    }
    if (tc <= tf) { //collision is/or about to occur
      jump(tc);
      clash();
      tf -= tc;
      tc = predict();
    } else {    //if (tf < tc) {
      jump(tf);
      tc -= tf;
      tf = dtf;
      ready = true;
    }
  } //level B
}

void jump(float t) {
  for (int i=0; i<n; i++) B[i]=P(B[i], t, V[i]);
} // advances all balls by time t


//******************************************************** PREDICT NEXT COLLISION/BOUNCE
float predict() // compute remainingTimeToFirstClash and colliders' IDs (ic,jc)
{
  float ltc=100000;
  ic=-1; 
  jc=-1;

  for (int i=0; i<n; i++) { //container
    float time = timeToBounce(i);
    if (time >= 0 && (time < ltc)) {
      ic = i;
      ltc = time;
    }
  }
  for (int i=1; i<n; i++) { //ball to ball collisions
    for (int j=0; j<i; j++) { 
      float time = timeToCollision(i, j);
      if (time >= 0 && (time < ltc)) {
        ic = i;
        jc = j;
        ltc = time;
      }
    }
  }
  return ltc;
}  

float timeToCollision(int i, int j) // time to collisions between balls i and j, or -1 if no collision
{ 
  VCT W = M(V[j], V[i]);
  VCT X = V(B[i], B[j]);
  float a = dot(W, W); //V^2+U^2+2VU
  float b = 2*dot(X, W); //2ABV + 2ABU
  float c =  dot(X, X)- sq((r+r)); //AB^2-(p+q)^2
  float d = sq(b) - 4 * a * c; //b^2 - 4ac
  if (d >= 0 && approaching(i, j, tf)) {
    float t1 = (-b - sqrt(d))/(2*a);
    float t2 = (-b + sqrt(d))/(2*a);
    //return min(t1, t2); //return when spheres initially hit
    if (t1 >= 0 && t2 >= 0) {
      return min(t1, t2); //return when spheres initially hit
    } else if (t1 < 0 && t2 >= 0) {
      return t2;
    } else if (t2 < 0 && t1 >= 0) {
      return t1;
    } else { 
      return -1;
    }
  }
  return -1; //spheres do not collide
} 

float timeToBounce(int i) // time to bounce with collider's border for ball i , or -1 if no collision
{
  VCT W = V[i];
  VCT X = V(C, B[i]);
  float a = dot(W, W); //V^2+U^2+2VU
  float b = 2*dot(X, W); //2ABV + 2ABU
  float c =  dot(X, X)- sq((rc-r)); //AB^2-(p+q)^2
  float d = sq(b) - 4 * a * c; //b^2 - 4ac
  if (d >= 0) {
    float t = (-b + sqrt(d))/(2*a);
    //return min(t1, t2); //return when spheres initially hit
    if (t >= 0) {
      return t; //return when spheres initially hit
    } else { 
      return -1;
    }
  }
  return -1; //spheres do not collide
}    

//******************************************************** TEST WHETHER BALL(S) MOVING TOWARDS COLLISION
boolean approaching(int i, int j, float t) // balls i & j will be aproaching each other  at time t
{

  //P + tV; -> point a/b at some time t
  PNT a = P(B[i], t, V[i]);
  PNT b = P(B[j], t, V[j]);
  return approaching(a, b, V[i], V[j]);
}  
boolean approaching(PNT A, PNT B, VCT X, VCT Y) // balls i & j will be aproaching each other  at time t
{
  VCT N = V(A, B);
  return (dot(N, V(1, Y, -1, X)) < 0); //V = V2 - V1
}  

boolean exiting(int i, float t) // balls i will overlap with the container border from inside at time t
{
  PNT a = P(B[i], t, V[i]);
  VCT N = V(a, C);
  return (dot(N, V(1, V(0, 0, 0), -1, V[i])) > 0); //V = V2 - V1
}  



//******************************************************** COMPUTE NEW VELOCITIES AFTER COLLISION OR BOUNCE
void clash() // computes new velocities after elasic collision with container or other ball
{
  if (jc==-1) {
    computeNewVelocitiesAfterBounceOffContainer(ic); 
    ic=-1;
  } else {
    computeNewVelocitiesAfterBounceBetweenColliders(ic, jc); 
    ic=-1; 
    jc=-1;
  }
}    

void computeNewVelocitiesAfterBounceOffContainer(int i) 
{
  VCT N = U(V(B[i], C)); //normal to collision plane
  VCT Un = V(dot(V[i], N), N); //normal to U;
  V[i] = A(V[i], -1.98, Un);
}

void computeNewVelocitiesAfterBounceBetweenColliders(int i, int j)
{
  VCT N = U(V(B[i], B[j])); //normal to collision plane
  VCT Un = V(dot(V[i], N), N); //normal to U;
  VCT Ut = M(V[i], Un); //tangential to U Ut = V[i] - Un

  VCT Vn = V(dot(V[j], N), N); //normal to V;
  VCT Vt = M(V[j], Vn); //tangential to V Vt = V[j] - Vn

  V[i] = A(Ut, .98, Vn); //V[i] = V[i] - Un + 0.98Vn
  V[j] = A(Vt, .98, Un); //V[j] = V[j] - Vn + 0.98Un
}
