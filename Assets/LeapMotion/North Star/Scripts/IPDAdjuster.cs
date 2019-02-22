/******************************************************************************
 * Copyright (C) Leap Motion, Inc. 2011-2018.                                 *
 *                                                                            *
 * Use subject to the terms of the Apache License 2.0 available at            *
 * http://www.apache.org/licenses/LICENSE-2.0, or another agreement           *
 * between Leap Motion and you, your company or other organization.           *
 ******************************************************************************/

using UnityEngine;

namespace Leap.Unity.AR {

  [ExecuteInEditMode]
  public class IPDAdjuster : MonoBehaviour {

    [Header("IPD")]
    public float ipd = 0.064f;
    public float heightOffset = -0.0048f;
    public float depthOffset = -0.0048f;
    private float? _lastKnownIPD = null;
    private float? _lastKnownHeight = null;
    private float? _lastKnownDepth = null;

    [Header("Left Eye")]
    [Tooltip("When IPD is adjusted, this transform's local X coordinate is moved.")]
    public Transform   leftEyeIPDTransform;
    [Tooltip("When IPD is adjusted, CalculateDistortionMesh() is called.")]
    public ARRaytracer leftEyeARRaytracer;

    [Header("Right Eye")]
    [Tooltip("When IPD is adjusted, this transform's local X coordinate is moved.")]
    public Transform   rightEyeIPDTransform;
    [Tooltip("When IPD is adjusted, CalculateDistortionMesh() is called.")]
    public ARRaytracer rightEyeARRaytracer;

    [Header("Hotkeys")]
    [Tooltip("Nudges the IPD wider by 1 millimeter.")]
    public KeyCode adjustWiderKey = KeyCode.RightArrow;
    [Tooltip("Nudges the IPD narrower by 1 millimeter.")]
    public KeyCode adjustNarrowerKey = KeyCode.LeftArrow;
    [Tooltip("Nudges the Eye Height higher by 1 millimeter.")]
    public KeyCode adjustHigherKey = KeyCode.UpArrow;
    [Tooltip("Nudges the Eye Height lower by 1 millimeter.")]
    public KeyCode adjustLowerKey = KeyCode.DownArrow;
    [Tooltip("Nudges the Eye Recession closer by 1 millimeter.")]
    public KeyCode adjustCloserKey = KeyCode.RightBracket;
    [Tooltip("Nudges the Eye Recession farther by 1 millimeter.")]
    public KeyCode adjustFartherKey = KeyCode.LeftBracket;

    private bool isConfigured {
      get {
        return !(leftEyeIPDTransform == null || leftEyeARRaytracer == null
                 || rightEyeIPDTransform == null || rightEyeARRaytracer == null);
      }
    }

    private void Start() {
      if (isConfigured) {
        ipd = rightEyeIPDTransform.localPosition.x * 2f;
        heightOffset = rightEyeIPDTransform.localPosition.y;
        depthOffset = rightEyeIPDTransform.localPosition.z;
      }
    }

    void Update() {
      if (!isConfigured) return;

      if (Application.isPlaying) {
        if (Input.GetKey(adjustWiderKey)) {
          ipd += 0.004f * Time.deltaTime;
        }
        if (Input.GetKey(adjustNarrowerKey)) {
          ipd -= 0.004f * Time.deltaTime;
        }
        if (Input.GetKey(adjustHigherKey)) {
          heightOffset += 0.01f * Time.deltaTime;
        }
        if (Input.GetKey(adjustLowerKey)) {
          heightOffset -= 0.01f * Time.deltaTime;
        }
        if (Input.GetKey(adjustLowerKey)) {
          heightOffset -= 0.01f * Time.deltaTime;
        }
        if (Input.GetKey(adjustCloserKey)) {
          depthOffset += 0.01f * Time.deltaTime;
        }
        if (Input.GetKey(adjustFartherKey)) {
          depthOffset -= 0.01f * Time.deltaTime;
        }
      }

      if (!_lastKnownIPD.HasValue || _lastKnownIPD.Value != ipd ||
          !_lastKnownHeight.HasValue || _lastKnownHeight.Value != heightOffset ||
          !_lastKnownDepth.HasValue || _lastKnownDepth.Value != depthOffset) {
        RefreshIPD();

        _lastKnownIPD = ipd;
        _lastKnownHeight = heightOffset;
        _lastKnownDepth = depthOffset;
      }
    }

    public void RefreshIPD() {
      Vector3 lPos = leftEyeIPDTransform.localPosition;
      Vector3 rPos = rightEyeIPDTransform.localPosition;
      lPos.x = -ipd / 2f; rPos.x = ipd / 2f;
      lPos.y = heightOffset; rPos.y = heightOffset;
      lPos.z = depthOffset; rPos.z = depthOffset;
      leftEyeIPDTransform.localPosition = lPos;
      rightEyeIPDTransform.localPosition = rPos;

      leftEyeARRaytracer.CreateDistortionMesh();
      rightEyeARRaytracer.CreateDistortionMesh();
    }

  }

}
