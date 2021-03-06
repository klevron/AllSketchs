import codeanticode.syphon.*;
SyphonServer server;

void settings() {
  size(684, 768, P3D); 
  PJOGL.profile=1;
}

Camera camera;
Scene actSce, sce, sce2;
PImage displace;
PShader post, glitch;
Windows windows;

void setup() {
  smooth(4);

  windows = new Windows();

  post = loadShader("post.glsl");
  post.set("resolution", float(width), float(height));
  glitch = loadShader("glitch.glsl");
  glitch.set("resolution", float(width), float(height));

  camera = new Camera();

  sce = new Scene1();
  sce2 = new Scene2();

  actSce = sce;

  displace = loadImage("luciana.jpg");
  post.set("displace", displace);


  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  post.set("time", millis()/1000.);
  glitch.set("time", millis()/10000.);

  windows.update();
  if (!windows.view) {
    drawWorld();
  }
  //drawInterface();
  //drawWorld();
  //filter(post);
  server.sendScreen();
}

void drawWorld() {
  if (random(20) < 0.3) {
    if (random(1) < 0.5) { 
      actSce = sce;
    } else {
      actSce = sce2;
    }
  }

  if (frameCount%200 == 0) camera.randomPosition();
  if (noise(millis()*0.000003) < 0.5) background(#151121);

  //camera.setFov(PI/(map(mouseY, 0, height, 1.5, 3)));
  //filter(BLUR, 0.1);
  pushMatrix();
  camera.update();
  actSce.update();
  actSce.show();
  popMatrix();

  post.set("chroma", cos(frameCount*0.01)*0.09+0.08);
  post.set("grain", noise(millis()*0.000008)*0.2-0.12);//
  //  post.set("grain", map(mouseX, 0, width, 0, 0.2));

  filter(post);
}

void keyPressed() {
  //if (key == 's') saveImage();
  //else {
  noiseSeed(int(random(999999999)));
  randomSeed(int(random(999999999)));
  camera.randomPosition();
  //}
  //camera.setFov(PI/(random(1, 5)));
}

void saveImage() {
  String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  saveFrame(timestamp+".png");
}

class Camera {
  PVector pos, rot;
  PVector vpos, vrot;
  Camera() {
    pos = new PVector();
    rot = new PVector();
    randomPosition();
  }
  void update() {
    pos.add(vpos);
    rot.add(vrot);
    translate(width/2, height/2, 0);
    translate(pos.x, pos.y, pos.z);

    rotateX(rot.x);
    rotateY(rot.y);
    rotateZ(rot.z);
  }

  void randomPosition() {
    pos = new PVector();
    pos.z = random(-400*random(1), 300);
    float vp = 0.1;
    float vr = 0.001;
    rot = new PVector(random(1), random(1), random(1));
    vrot = new PVector(random(-vr, vr), random(-vr, vr), random(-vr, vr)); 
    vpos = new PVector(random(-vp, vp), random(-vp, vp), random(-vp, vp));
  }

  void setFov(float fov) {
    float cameraZ = (height/2.0) / tan(fov/2.0);
    perspective(fov, float(width)/float(height), 
    cameraZ/10.0, cameraZ*10.0);
  }
}