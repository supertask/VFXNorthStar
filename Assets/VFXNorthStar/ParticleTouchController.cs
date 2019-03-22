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
    private HandUtil handUtil;

    void Start() { this.Init(); }

    private void Init() {
        this.m_Provider = this.leapProviderObj.GetComponent<LeapServiceProvider>();
        this.handUtil = new HandUtil();
    }


    void Update()
    {
        Frame frame = this.m_Provider.CurrentFrame;
        Hand[] hands = HandUtil.GetCorrectHands(frame); //0=LEFT, 1=RIGHT

        if (this.handUtil.JustOpenedHandOn(hands[HandUtil.LEFT], HandUtil.LEFT)) {
            Debug.Log("Just OPENED LEFT hand");
        }
        else if (this.handUtil.JustClosedHandOn(hands[HandUtil.LEFT], HandUtil.LEFT)) {
            Debug.Log("Just CLOSED LEFT hand");
        }

        if (this.handUtil.JustOpenedHandOn(hands[HandUtil.RIGHT], HandUtil.RIGHT)) {
            Debug.Log("Just OPENED RIGHT hand");
        }
        else if (this.handUtil.JustClosedHandOn(hands[HandUtil.RIGHT], HandUtil.RIGHT)) {
            Debug.Log("Just CLOSED RIGHT hand");
        }

        this.handUtil.SaveHandsState(hands);

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
        //if (Input.GetKeyUp(KeyCode.F)) {
    }
}
