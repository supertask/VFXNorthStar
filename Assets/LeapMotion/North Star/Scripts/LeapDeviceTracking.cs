/******************************************************************************
 * Copyright (C) Leap Motion, Inc. 2011-2018.                                 *
 *                                                                            *
 * Use subject to the terms of the Apache License 2.0 available at            *
 * http://www.apache.org/licenses/LICENSE-2.0, or another agreement           *
 * between Leap Motion and you, your company or other organization.           *
 ******************************************************************************/

using System;
using UnityEngine;

namespace Leap.Unity.AR {
  public class LeapDeviceTracking : MonoBehaviour {
    [Tooltip("The Leap Service Provider for the Device that is Attached to the Headset")]
    public LeapServiceProvider LeapProvider;
    [Tooltip("Extrapolation amount in Milliseconds")]
    public int ExtrapolationAmount = 30;

    [NonSerialized]
    public Vector3 devicePosition;
    [NonSerialized]
    public Quaternion deviceRotation;
    private Vector3 positionalDrift = Vector3.zero;

    void LateUpdate() {
      if (Input.GetKeyDown(KeyCode.R)) {
        positionalDrift = devicePosition + positionalDrift - transform.parent.position;
      }

      LeapInternal.LEAP_HEAD_POSE_EVENT headEvent = new LeapInternal.LEAP_HEAD_POSE_EVENT();
      LeapProvider.GetLeapController().GetInterpolatedHeadPose(ref headEvent, 
                                                               LeapProvider.CurrentFrame.Timestamp + 
                                                               ExtrapolationAmount * 1000);

      devicePosition = headEvent.head_position.ToVector3() / 1000f;
      devicePosition = new Vector3(-devicePosition.x, -devicePosition.z, devicePosition.y);

      deviceRotation = Quaternion.LookRotation(Vector3.up, -Vector3.forward) *
                            headEvent.head_orientation.ToQuaternion() *
    Quaternion.Inverse(Quaternion.LookRotation(Vector3.up, -Vector3.forward));


      if (devicePosition != Vector3.zero && !devicePosition.ContainsNaN()) {
        devicePosition -= positionalDrift;
        transform.localPosition = devicePosition;
        transform.localRotation = deviceRotation;
      }
    }
  }
}
