using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;
using UnityEngine.Experimental.VFX;

struct AttractorParam
{
    public Vector3 scale;
    public float distance; //Distance between attractor position and hand palm position
    public Quaternion addQuaternion;
    public AttractorParam(float s, float d, Quaternion aq) {
        this.scale = new Vector3(s, s, s);
        this.distance = d;
        this.addQuaternion = aq;
    }
}

public class ParticleTouchController : MonoBehaviour
{
    public GameObject leapProviderObj = null;
    public bool IsAttractorOnLeftHand = false;
    public List<GameObject> attractors;

    private LeapServiceProvider m_Provider;
    private GameObject selecting;

    private HandUtil handUtil;

    private int curAttractorIndex;
    private GameObject curAttractor; //Current attractor
    private bool IsFingerEffector;
    private int attractorHandId;
    private int effectorHandId;
    private AttractorParam[] attractorParams;
    private Hand[] previousHands;

    void Start() { this.Init(); }

    private void Init() {
        this.m_Provider = this.leapProviderObj.GetComponent<LeapServiceProvider>();
        this.handUtil = new HandUtil();
        this.IsFingerEffector = false;
        this.curAttractorIndex = 0;
        this.attractorHandId = this.IsAttractorOnLeftHand ? HandUtil.LEFT : HandUtil.RIGHT;
        this.effectorHandId = this.IsAttractorOnLeftHand ? HandUtil.RIGHT : HandUtil.LEFT;
        this.attractorParams = new AttractorParam[2] {
            // Scale, Distance, AdditionalRotation
            new AttractorParam(0.04f, 0.25f, Quaternion.Euler(0, 0, 0)), //ThomasCyclicallySymmetricAttractor
            new AttractorParam(0.01f, 0.2f, Quaternion.Euler(0, 0, 0)) //LorenzAttractor
        };
        for (int i = 0; i< this.attractorParams.Length; i++) {
            attractors[i].transform.localScale = this.attractorParams[i].scale;
        }
        this.previousHands = new Hand[2];
    }


    void Update()
    {
        Frame frame = this.m_Provider.CurrentFrame;
        Hand[] hands = HandUtil.GetCorrectHands(frame); //0=LEFT, 1=RIGHT

        if (this.handUtil.JustOpenedHandOn(hands, this.attractorHandId)) {
            Debug.Log("Just OPENED RIGHT hand");
            //Show attractor
            this.curAttractor = this.attractors[this.curAttractorIndex];
            this.curAttractor.GetComponent<VisualEffect>().enabled = true;
        }
        else if (this.handUtil.JustClosedHandOn(hands, this.attractorHandId)) {
            Debug.Log("Just CLOSED RIGHT hand");

            //Unshow attractor
            this.curAttractor.GetComponent<VisualEffect>().enabled = false;
            this.curAttractorIndex = (this.curAttractorIndex + 1) % this.attractors.Count; //Go next attractor
        }

        if (this.handUtil.JustOpenedFingerOn(hands, this.effectorHandId, (int)Finger.FingerType.TYPE_INDEX)) {
            Debug.Log("Just OPENED RIGHT index finger");
            GameObject attractor = this.attractors[this.curAttractorIndex];

            this.IsFingerEffector = true;
        }
        else if (this.handUtil.JustClosedFingerOn(hands, this.effectorHandId, (int)Finger.FingerType.TYPE_INDEX)) {
            Debug.Log("Just CLOSED RIGHT index finger");
            this.IsFingerEffector = false;
        }

        if (this.curAttractor != null) {
            //Attractor exists
            Hand hand = hands[this.attractorHandId];
            if (hand != null) {
                AttractorParam param = this.attractorParams[this.curAttractorIndex];
                Vector attractorPos = hand.PalmPosition + param.distance * hand.PalmNormal;
                this.curAttractor.transform.position = HandUtil.GetVector3(attractorPos);
                this.curAttractor.transform.rotation = HandUtil.GetQuaternion(hand.Rotation) * param.addQuaternion;
            }
        }
        if (this.IsFingerEffector) {
        }
 
        this.handUtil.SavePreviousHands(hands);
        this.handUtil.SavePreviousFingers(hands);

        this.previousHands = hands;

        //if (Input.GetKeyUp(KeyCode.F)) {
    }
}
