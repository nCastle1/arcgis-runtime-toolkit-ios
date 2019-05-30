// Copyright 2019 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ARKit

//import ArcGISToolkit
//import ArcGIS

open class ARExample: UIViewController {
    
    public let arView = ArcGISARView(frame: CGRect.zero)
//    public let arView = ArcGISARView(renderVideoFeed: false)
//    public let arView = ArcGISARSensorView(renderVideoFeed: true)

    let fovLabel: UILabel = UILabel(frame: .zero)
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        arView.delegate = self
        
        //
        // Short and fat
        //

        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            arView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
//            arView.widthAnchor.constraint(equalToConstant: 200.0),
            arView.heightAnchor.constraint(equalToConstant:200.0)
//            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.addSubview(fovLabel)
        fovLabel.translatesAutoresizingMaskIntoConstraints = false
        fovLabel.textColor = .blue
        NSLayoutConstraint.activate([
            fovLabel.centerXAnchor.constraint(equalTo: arView.centerXAnchor, constant: 0),
            fovLabel.topAnchor.constraint(equalTo: arView.bottomAnchor, constant: 16),
            ])
        
        //
        // Tall and skinny
        //
        
//        view.addSubview(arView)
//        arView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 200),
//            //            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            arView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//            arView.widthAnchor.constraint(equalToConstant: 200.0),
//            //            arView.heightAnchor.constraint(equalToConstant:200.0)
//            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ])
//
//        view.addSubview(fovLabel)
//        fovLabel.translatesAutoresizingMaskIntoConstraints = false
//        fovLabel.textColor = .blue
//        NSLayoutConstraint.activate([
//            fovLabel.leadingAnchor.constraint(equalTo: arView.trailingAnchor, constant: 0),
//            fovLabel.centerYAnchor.constraint(equalTo: arView.centerYAnchor, constant: 16),
//            ])
        
        arView.sceneView.scene = scene()
//        arView.sceneView.alpha = 0.5
        
//        camera heading: 318.9702215288517, pitch = 52.69900468516913, roll = 0.6234908971981902, location = AGSPoint: (-93.298481, 44.940544, 274.055704, nan), sr: 4326

        let originCamera = AGSCamera(latitude: 44.940544, longitude: -93.298481, altitude: 274.055704, heading: 270.0, pitch: 0.0, roll: 0.0)
        arView.originCamera = originCamera
        
        let camera = AGSCamera(latitude: 44.940544, longitude: -93.298481, altitude: 274.055704, heading: 270.0, pitch: 90.0, roll: 0.0)
        addPointToScene(camera: camera)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        arView.startTracking()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        arView.stopTracking()
    }
    
    private func scene() -> AGSScene {

        // create scene
        let scene = AGSScene(basemapType: .streets)
//        let scene = AGSScene()

        // create elevation surface
        let elevationSource = AGSArcGISTiledElevationSource(url: URL(string: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!)
        let surface = AGSSurface()
        surface.elevationSources = [elevationSource]
        surface.name = "baseSurface"
        surface.isEnabled = true
        surface.backgroundGrid.isVisible = false
        scene.baseSurface = surface
        
        return scene
    }

    //
    // Debug - show point in front of camera...
    //
    private func addPointToScene(camera: AGSCamera) {
        
        let go = AGSGraphicsOverlay()
        go.sceneProperties = AGSLayerSceneProperties(surfacePlacement: .absolute)
        arView.sceneView.graphicsOverlays.add(go)
        
        let markerSymbol = AGSSimpleMarkerSceneSymbol(style: .diamond, color: .blue, height: 0.1, width: 0.1, depth: 0.1, anchorPosition: .bottom)
        
        //  move camera forward 1 meters and get location
        let location = camera.moveForward(withDistance: 5.0).location
        
        let graphic = AGSGraphic(geometry: location, symbol: markerSymbol, attributes: nil)
        go.graphics.add(graphic)
    }
}

extension ARExample: ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let currentFrame = session.currentFrame else { return }
        let projectionMatrix = currentFrame.camera.projectionMatrix
        let verticalElement = projectionMatrix.columns.0.x
        let horizontalElement = projectionMatrix.columns.1.y
        fovLabel.text = String("FOV-vert: \(verticalElement) horiz: \(horizontalElement)")
//        fovLabel.text = String("sceneView.fieldOfView = horizontalElement: \(horizontalElement) fieldOfViewDistortionRatio = \(arView.sceneView.fieldOfViewDistortionRatio)")

    }
}
