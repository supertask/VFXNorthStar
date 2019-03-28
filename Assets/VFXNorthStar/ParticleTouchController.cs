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
    public List<float> attractorDistances;
    public List<float> attractorScales;
    public List<Vector3> attractorAddQuaternions;
    public List<Vector3> attractorAddPositions;
    public GameObject fingerTip;

    private LeapServiceProvider m_Provider;
    private GameObject selecting;

    private HandUtil handUtil;

    private int curAttractorIndex;
    private GameObject curAttractor; //Current attractor
    private bool IsFingerEffector;
    private int attractorHandId;
    private int effectorHandId;
    private Hand[] previousHands;

    void Start() { this.Init(); }

    private void Init() {
        this.m_Provider = this.leapProviderObj.GetComponent<LeapServiceProvider>();
        this.handUtil = new HandUtil();
        this.IsFingerEffector = false;
        this.curAttractorIndex = 0;
        this.attractorHandId = this.IsAttractorOnLeftHand ? HandUtil.LEFT : HandUtil.RIGHT;
        this.effectorHandId = this.IsAttractorOnLeftHand ? HandUtil.RIGHT : HandUtil.LEFT;
        for (int i = 0; i< this.attractorScales.Count; i++) {
            float s = this.attractorScales[i];
            attractors[i].transform.localScale = new Vector3(s,s,s);
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
            this.IsFingerEffector = true;
        }
        else if (this.handUtil.JustClosedFingerOn(hands, this.effectorHandId, (int)Finger.FingerType.TYPE_INDEX)) {
            Debug.Log("Just CLOSED RIGHT index finger");
            this.IsFingerEffector = false;
        }

        //Attractor and hand exists
        if (this.curAttractor != null && hands[this.attractorHandId] != null) {
            Hand hand = hands[this.attractorHandId];

            //手の中心とアトラクターとの距離から表示位置を割り出す
            Vector attractorPos = hand.PalmPosition +
                    this.attractorDistances[this.curAttractorIndex] * hand.PalmNormal;

            //アトラクターの位置を補正（attractorAddPositions）
            this.curAttractor.transform.position = HandUtil.GetVector3(attractorPos) +
                    this.attractorAddPositions[this.curAttractorIndex];
            //アトラクターの回転を補正（attractorAddQuaternions）
            this.curAttractor.transform.rotation = HandUtil.GetQuaternion(hand.Rotation) *
                    Quaternion.Euler(this.attractorAddQuaternions[this.curAttractorIndex]);
        }

        //FingerEffect and hand exists
        if (this.IsFingerEffector && hands[this.effectorHandId] != null) {

            Finger indexFinger = hands[this.effectorHandId].Fingers[(int)Finger.FingerType.TYPE_INDEX];
            Vector3 tipPosition = HandUtil.GetVector3(indexFinger.TipPosition);
            this.fingerTip.transform.position = tipPosition;
            //Debug.Log("tipPos: " + tipPosition);
        }
 
        this.handUtil.SavePreviousHands(hands);
        this.handUtil.SavePreviousFingers(hands);

        this.previousHands = hands;

        //if (Input.GetKeyUp(KeyCode.F)) {
    }
}
