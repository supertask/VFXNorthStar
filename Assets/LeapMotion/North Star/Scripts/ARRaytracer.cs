/******************************************************************************
 * Copyright (C) Leap Motion, Inc. 2011-2018.                                 *
 *                                                                            *
 * Use subject to the terms of the Apache License 2.0 available at            *
 * http://www.apache.org/licenses/LICENSE-2.0, or another agreement           *
 * between Leap Motion and you, your company or other organization.           *
 ******************************************************************************/

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap.Unity.RuntimeGizmos;
using System.Text;
using System.IO;

namespace Leap.Unity.AR {
  public class ARRaytracer : MonoBehaviour, IRuntimeGizmoComponent {
    public Camera eyePerspective;
    public EllipsoidTransform ellipse;
    public Transform Screen;
    public MeshFilter filter;
    public Vector2 meshResolution = new Vector2(10, 10);
    public CalibrationDeformer deformer;
    [Range(0.5f, 2f)]
    public float aspectRatio = 0.8f;

    [Tooltip("Auto-recalculates the distortion mesh once every five frames when in Play "
           + "mode in the editor.")]
    public bool autoRefreshRuntimeEditor = true;

    private Mesh _backingDistortionMesh = null;
    private Mesh _distortionMesh {
      get {
        if (_backingDistortionMesh == null) {
          _backingDistortionMesh = new Mesh();
        }
        return _backingDistortionMesh;
      }
    }
    List<Vector2> meshUVs = new List<Vector2>(100);
    List<Vector3> meshVertices = new List<Vector3>(100);
    List<int> meshTriangles = new List<int>(600);

    void Start() {
      if (eyePerspective == null) { eyePerspective = GetComponent<Camera>(); eyePerspective.aspect = aspectRatio; }
      if (deformer == null) { deformer = eyePerspective.transform.parent.GetComponent<CalibrationDeformer>(); }
      eyePerspective.aspect = aspectRatio;

      CreateDistortionMesh();
      Application.targetFrameRate = -1000;
      /*
      StringBuilder builder = new StringBuilder();
      builder.AppendLine("CameraU, CameraV, DisplayU, DisplayV");
      for(int i = 0; i< meshUVs.Count; i++) {
        //builder.AppendLine(meshUVs[i].x + ", " + meshUVs[i].y + ", " + meshVertices[i].x + ", " + meshVertices[i].y);
        builder.AppendLine("[ [" + (meshVertices[i].y + 0.5f) + ", " + (meshVertices[i].x + 0.5f) + "], [" + meshUVs[i].x + "," + meshUVs[i].y + "] ],");
      }

      File.WriteAllText(Directory.GetParent(Application.dataPath).FullName + "/ARReflectorHomography.csv", builder.ToString());*/
    }


    public void OnDrawRuntimeGizmos(RuntimeGizmoDrawer drawer) {
      if (eyePerspective == null) { eyePerspective = GetComponent<Camera>(); eyePerspective.aspect = 1.111f; }
      if (!Application.isPlaying) {
        CreateDistortionMesh(drawer);
      }
    }

    private void LateUpdate() {

#if UNITY_EDITOR
      if (autoRefreshRuntimeEditor && Time.frameCount % 5 == 0) {
        CreateDistortionMesh();
      }
#endif

      // Nice to calculate the distortion mesh after the first Start() and Update().
      if (Time.time < 1.0f) { CreateDistortionMesh(); }
    }

    [ContextMenu("Create Distortion Mesh")]
    public void CreateDistortionMesh(RuntimeGizmoDrawer drawer = null) {
      if (eyePerspective == null) { eyePerspective = GetComponent<Camera>(); }/// 1.12f; }
      eyePerspective.aspect = aspectRatio;

      ellipse.UpdateEllipsoid();

      meshVertices.Clear();
      meshUVs.Clear();
      meshTriangles.Clear();

      //Full range = 0f - 1f
      for (float i = 0; i <= meshResolution.x; i++) {
        for (float j = 0; j <= meshResolution.y; j++) {
          Vector2 RenderUV = new Vector2(i / meshResolution.x, j / meshResolution.y);
          meshUVs.Add(RenderUV);
          meshVertices.Add(RenderUVToDisplayUV(RenderUV, (i % 5 == 0 && j % 5 == 0), drawer) - (Vector2.one * 0.5f));

          //drawer.DrawSphere(filter.transform.TransformPoint(meshVertices[meshVertices.Count - 1]), 0.005f);
        }
      }

      for (int x = 1; x <= meshResolution.x; x++) {
        for (int y = 1; y <= meshResolution.y; y++) {
          //Adds the index of the three vertices in order to make up each of the two tris
          meshTriangles.Add((int)meshResolution.x * x + y); //Top right
          meshTriangles.Add((int)meshResolution.x * x + y - 1); //Bottom right
          meshTriangles.Add((int)meshResolution.x * (x - 1) + y - 1); //Bottom left - First triangle
          meshTriangles.Add((int)meshResolution.x * (x - 1) + y - 1); //Bottom left 
          meshTriangles.Add((int)meshResolution.x * (x - 1) + y); //Top left
          meshTriangles.Add((int)meshResolution.x * x + y); //Top right - Second triangle
        }
      }

      _distortionMesh.SetVertices(meshVertices);
      _distortionMesh.SetUVs(0, meshUVs);
      _distortionMesh.SetTriangles(meshTriangles, 0);
      _distortionMesh.RecalculateNormals();

      if (filter != null) {
        filter.sharedMesh = _distortionMesh;
      }

      if (deformer != null) { deformer.InitializeMeshDeformations(); }
    }

    public Vector2 RenderUVToDisplayUV(Vector2 UV, bool drawLine = false, RuntimeGizmoDrawer drawer = null) {
      Ray eyeRay = eyePerspective.ViewportPointToRay(new Vector3(UV.x, UV.y, 1f));
      eyeRay.origin = eyePerspective.transform.position;
      Vector3 sphereSpaceRayOrigin = ellipse.worldToSphereSpace.MultiplyPoint(eyeRay.origin);
      Vector3 sphereSpaceRayDirection = (ellipse.worldToSphereSpace.MultiplyPoint(eyeRay.origin + eyeRay.direction) - sphereSpaceRayOrigin).normalized;
      float intersectionTime = intersectLineSphere(sphereSpaceRayOrigin, sphereSpaceRayDirection, Vector3.zero, 0.5f * 0.5f, false);
      if (intersectionTime < 0f) { return Vector2.zero; }
      Vector3 sphereSpaceIntersection = sphereSpaceRayOrigin + (intersectionTime * sphereSpaceRayDirection);

      //Ellipsoid  Normals
      Vector3 sphereSpaceNormal = -sphereSpaceIntersection.normalized;
      sphereSpaceNormal = new Vector3(sphereSpaceNormal.x / Mathf.Pow(ellipse.MinorAxis / 2f, 2f), sphereSpaceNormal.y / Mathf.Pow(ellipse.MinorAxis / 2f, 2f), sphereSpaceNormal.z / Mathf.Pow(ellipse.MajorAxis / 2f, 2f)).normalized;

      Vector3 worldSpaceIntersection = ellipse.sphereToWorldSpace.MultiplyPoint(sphereSpaceIntersection);
      Vector3 worldSpaceNormal = ellipse.sphereToWorldSpace.MultiplyVector(sphereSpaceNormal).normalized;

      Ray firstBounce = new Ray(worldSpaceIntersection, Vector3.Reflect(eyeRay.direction, worldSpaceNormal));

      intersectionTime = intersectPlane(Screen.forward, Screen.position, firstBounce.origin, firstBounce.direction);
      if (intersectionTime < 0f) { return Vector2.zero; }
      Vector3 planeIntersection = firstBounce.GetPoint(intersectionTime);

      Vector2 ScreenUV = Screen.InverseTransformPoint(planeIntersection);

      if (drawer != null) {
        if (drawLine) {
          drawer.DrawLine(eyeRay.origin, worldSpaceIntersection);
          drawer.DrawLine(firstBounce.origin, planeIntersection);
        }
        //drawer.DrawSphere(firstBounce.origin, 0.0005f);
        //drawer.DrawSphere(((firstBounce.origin - eyeRay.origin) * 1f) + eyeRay.origin, 0.0005f);
        //drawer.DrawSphere(planeIntersection, 0.0005f);
      }

      //ScreenUV = new Vector2(Mathf.Clamp01(ScreenUV.x + 0.5f), Mathf.Clamp01(ScreenUV.y + 0.5f));
      ScreenUV = new Vector2((ScreenUV.x + 0.5f), /*Mathf.Clamp01*/(ScreenUV.y + 0.5f));

      return ScreenUV;
    }

    float intersectLineSphere(Vector3 Origin, Vector3 Direction, Vector3 spherePos, float SphereRadiusSqrd, bool frontSide = true) {
      Vector3 L = spherePos - Origin;
      Vector3 offsetFromSphereCenterToRay = Vector3.Project(L, Direction) - L;
      return (offsetFromSphereCenterToRay.sqrMagnitude <= SphereRadiusSqrd) ? Vector3.Dot(L, Direction) - (Mathf.Sqrt(SphereRadiusSqrd - offsetFromSphereCenterToRay.sqrMagnitude) * (frontSide ? 1f : -1f)) : -1f;
    }

    float intersectPlane(Vector3 n, Vector3 p0, Vector3 l0, Vector3 l) {
      float denom = Vector3.Dot(-n, l);
      if (denom > float.Epsilon) {
        Vector3 p0l0 = p0 - l0;
        float t = Vector3.Dot(p0l0, -n) / denom;
        return t;
      }
      return -1f;
    }
  }
}
