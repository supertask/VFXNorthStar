using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;

public class ParticleTouchController : MonoBehaviour
{
    public GameObject leapProviderObj;
    LeapServiceProvider m_Provider;
    private GameObject selecting;

    void Start() { this.Init(); }

    private void Init() {
        this.m_Provider = this.leapProviderObj.GetComponent<LeapServiceProvider>();
    }


    void Update()
    {
        if (this.mode == FORCE) {
            //フォースモード
            Frame frame = this.m_Provider.CurrentFrame;
            Hand[] hands = this.GetCorrectHands(frame);

            if (HandUtil.OpenedHandTrigger(hands[HandUtil.LEFT], HandUtil.LEFT)) {
                Debug.Log("Just OPENED LEFT hand");
            }
            else if (HandUtil.ClosedHandTrigger(hands[HandUtil.LEFT], HandUtil.LEFT)) {
                Debug.Log("Just CLOSED LEFT hand");
            }

            if (HandUtil.OpenedHandTrigger(hands[HandUtil.RIGHT], HandUtil.RIGHT)) {
                Debug.Log("Just OPENED RIGHT hand");
            }
            else if (HandUtil.ClosedHandTrigger(hands[HandUtil.RIGHT], HandUtil.RIGHT)) {
                Debug.Log("Just CLOSED RIGHT hand");
            }

            /*
            if (hands[HandUtil.RIGHT] != null) {
                if (this.isOpenHands[HandUtil.RIGHT] && !this.IsOpenFiveFingers(hands[HandUtil.RIGHT])) {
                    this.isOpenHands[HandUtil.RIGHT] = false; //closed hand
                }
                else if (!this.isOpenHands[HandUtil.RIGHT] && this.IsOpenFiveFingers(hands[HandUtil.RIGHT])) {
                    this.isOpenHands[HandUtil.RIGHT] = true; //opened hand
                    Debug.Log("right hand opened");
                }
            }
            */
        }

        //if (Input.GetKeyUp(KeyCode.F)) {
    }
}
