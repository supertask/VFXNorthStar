using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;

public class HandUtil
{
    public static int LEFT = 0;
    public static int RIGHT = 1;
    private bool[] isOpendHands;

    public HandUtil() {
        this.openedHands = new bool[2] { false, false };
    }

    /*
     * 
     * Leap Motionのframe.Handsのindexはleft, rightに対応していないため
     *
     * @param
     *     frame: One frame
     * @return
     *     hand[0]: Left hand
     *     hand[1]: Right hand
     */
    public static Hand[] GetCorrectHands(Frame frame)
    {
        Hand[] hands = new Hand[2];
        if (frame.Hands.Count >= 2) {
            hands[LEFT] = frame.Hands[0].IsLeft ? frame.Hands[0] : frame.Hands[1];
            hands[RIGHT] = frame.Hands[1].IsRight ? frame.Hands[1] : frame.Hands[0];
        }
        else if (frame.Hands.Count == 1) {
            hands[LEFT] = frame.Hands[0].IsLeft ? frame.Hands[0] : null;
            hands[RIGHT] = frame.Hands[0].IsRight ? frame.Hands[0] : null;
        }
        else { hands[LEFT] = hands[RIGHT] = null; }
        return hands;
    }


    /*
     * すべての指が開いているかを返す
     */
    public static bool IsOpenedFiveFingers(Hand hand)
    {
        foreach (Finger f in hand.Fingers) {
            if (! f.IsExtended) { return false; }
        }
        return true;
    }


    public static bool OpenedHandTrigger(Hand hand, int handId)
    {
        //過去手を閉じていて，現在の手が存在し，その手の指が全部開くとき
        if (!this.isOpenHands[handId] && hand != null && this.IsOpenFiveFingers(hand) {
            this.isOpenHands[handId] = true; //Just opened hand
            return true; //Not Opened
        }
        return false; //Not Opened
    }

    public static bool ClosedHandTrigger(Hand hand, int handId)
    {
        //過去手を開いていて，現在の手が存在し，その手の指が全部閉じるとき
        if (this.openedHands[handId] && hand != null && !HandUtil.IsOpenFiveFingers(hand)) {
            this.isOpenHands[handId] = false; //Just closed hand
            return true; //Closed
        }
        return false; //Not Closed
    }


    public static Vector3 GetVector3(Vector v) {
        return new Vector3(v.x, v.y, v.z);
    }
}
