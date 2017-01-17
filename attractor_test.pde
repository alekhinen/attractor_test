// M_4_2_01.pde
// Attractor.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * a simple attractor utilizing Kinect skeleton data.
 * original code from Generative Gestaltung.
 * modifications made by Nick Alekhine.
 *
 * KEYS
 * r                 : reset nodes
 */

import generativedesign.*;

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

int xCount = 300;
int yCount = 100;
float gridSize = 900;
float attractorStrength = 3;

// nodes array 
OriginNode[] myNodes = new OriginNode[xCount*yCount];

// attractor
Attractor leftAttractor;
Attractor rightAttractor;

void setup() {  
  size(1680, 1050); 

  // setup drawing parameters
  colorMode(RGB, 255, 255, 255, 100);
  smooth();
  noStroke();

  background(255); 

  cursor(CROSS);

  // setup node grid
  initGrid();

  // setup attractor
  leftAttractor = new Attractor(0, 0);
  rightAttractor = new Attractor(0, 0);
  
  // initialize kinect stuff. 
  initKinect();
}

void initKinect() {
  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);
  kinect.enableColorImg(true);
  kinect.enableSkeletonColorMap(true);

  kinect.init();
}

void draw() {
  fill(255, 10);
  rect(0, 0, width, height);
  
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      
      // no need for the chest coord??
      //PVector chest = mapDepthToScreen(joints[KinectPV2.JointType_SpineMid]);
      PVector lHand = mapDepthToScreen(joints[KinectPV2.JointType_HandLeft]);
      PVector rHand = mapDepthToScreen(joints[KinectPV2.JointType_HandRight]);

      int lHandState = joints[KinectPV2.JointType_HandLeft].getState();
      int rHandState = joints[KinectPV2.JointType_HandRight].getState();
      
      leftAttractor.x = lHand.x;
      leftAttractor.y = lHand.y;
      
      rightAttractor.x = rHand.x;
      rightAttractor.y = rHand.y;
      
      for (int j = 0; j < myNodes.length; j++) {
        if (lHandState == KinectPV2.HandState_Closed) {
          // repulsion
          leftAttractor.strength = attractorStrength; 
        } else {
          // attraction
          leftAttractor.strength = -attractorStrength; 
        }
        
        leftAttractor.attract(myNodes[j]);
        
        if (rHandState == KinectPV2.HandState_Closed) {
          // repulsion
          rightAttractor.strength = -attractorStrength; 
        } else {
          // attraction
          rightAttractor.strength = attractorStrength; 
        }
        
        rightAttractor.attract(myNodes[j]);
    
        myNodes[j].update();
      }
    }
  }
  
  boolean noSkeletons = skeletonArray.size() == 0;
  
  for (int j = 0; j < myNodes.length; j++) {
    
    if (noSkeletons) {
      myNodes[j].update();
    }
    
    // draw nodes
    fill(0);
    rect(myNodes[j].x, myNodes[j].y, 1, 1);
  }

}


void initGrid() {
  int i = 0; 
  for (int y = 0; y < yCount; y++) {
    for (int x = 0; x < xCount; x++) {
      float xPos = x*(gridSize/(xCount-1))+(width-gridSize)/2;
      float yPos = y*(gridSize/(yCount-1))+(height-gridSize)/2;
      myNodes[i] = new OriginNode(xPos, yPos);
      myNodes[i].setBoundary(0, 0, width, height);
      myNodes[i].setDamping(0.02);  //// 0.0 - 1.0
      i++;
    }
  }
}


void keyPressed() {
  if (key=='r' || key=='R') {
    initGrid();
  }
}

PVector mapDepthToScreen(KJoint joint) {
  int x = Math.round(map(joint.getX(), 0, 1920, 0, 1680));
  int y = Math.round(map(joint.getY(), 0, 1080, 0, 1050));
  int z = Math.round(joint.getZ());
  return new PVector(x, y, z);
}