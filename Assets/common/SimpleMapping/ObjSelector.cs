using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;
using System.Linq;

public class ObjSelector : MonoBehaviour
{
    public GameObject leapProviderObj;
    LeapServiceProvider m_Provider;
    private LayerMask FIELD_LAYER;
    public static float CASTING_SIZE = 0.05f; //diameter = 0.1m

    private GameObject selecting;

    void Start() {
        this.FIELD_LAYER = LayerMask.GetMask("Field");
        this.m_Provider = this.leapProviderObj.GetComponent<LeapServiceProvider>();
        this.selecting = GameObject.Find("Selecting");

    }

    void Update()
    {
        Frame frame = this.m_Provider.CurrentFrame;
        foreach (Hand hand in frame.Hands)
        {
            Vector3 src = this.GetVector3(hand.PalmPosition);
            Vector3 target = this.GetVector3(hand.PalmNormal);
            //Debug.DrawLine(src, target * 3, Color.red);
            RaycastHit[] hitObjects = Physics.SphereCastAll(src, ObjSelector.CASTING_SIZE,
                target, Mathf.Infinity, FIELD_LAYER);
            this.SelectObjects(hitObjects);
        }


        //Hand leftHand = frame.Hands[0].IsLeft ? frame.Hands[0] : frame.Hands[1];
        //Hand rightHand = frame.Hands[1].IsRight ? frame.Hands[1] : frame.Hands[0];

        //var isHit = Physics.Raycast(transform.position, transform.forward, out hit, 100);

    }

    public void SelectObjects(RaycastHit[] hitObjs)
    {
        foreach (RaycastHit obj in hitObjs)
        {
            obj.transform.parent = this.selecting.transform;
        }
    }

    private Vector3 GetVector3(Vector v)
    {
        return new Vector3(v.x, v.y, v.z);
    }

    public static void MapObjects()
    {
        GameObject selecting = GameObject.Find("Selecting");
        GameObject mappedObj = GameObject.Find("Mapped");

        // Normal foreach(var t in transform) can't use in this case.
        // Because a number of the child transforms is changed in foreach
        // Solution: https://answers.unity.com/questions/605341/why-does-foreach-work-only-12-of-a-time.html
        List<Transform> copiedSelectingTransforms = selecting.transform.Cast<Transform>().ToList();
        foreach (Transform selectingTrans in copiedSelectingTransforms) {
            selectingTrans.parent = mappedObj.transform;
        }
    }

    public static void SelectMappedObjects()
    {
        GameObject selecting = GameObject.Find("Selecting");
        GameObject mapped = GameObject.Find("Mapped");

        // Normal foreach(var t in transform) can't use in this case.
        // Because a number of the child transforms is changed in foreach
        // Solution: https://answers.unity.com/questions/605341/why-does-foreach-work-only-12-of-a-time.html
        List<Transform> copiedMappedTransforms = mapped.transform.Cast<Transform>().ToList();
        foreach (Transform mappedTrans in copiedMappedTransforms) {
            mappedTrans.parent = selecting.transform;
        }
    }
}
