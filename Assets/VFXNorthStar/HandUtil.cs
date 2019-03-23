using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;

public class HandUtil
{
    public static int LEFT = 0;
    public static int RIGHT = 1;
    private bool[] isOpenedPreviousHands;
    private Hand[] previousHands;

    public HandUtil() {
        this.isOpenedPreviousHands = new bool[2];
        this.isOpenedPreviousHands.Fill(false);
        this.previousHands = new Hand[2];
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
     * Returns whether your five fingers are opened
     * @param hand Leap.Hand left or right hand
     * @return whether your five fingers are opened
     */
    public static bool IsOpenedFiveFingers(Hand hand)
    {
        foreach (Finger f in hand.Fingers) {
            if (! f.IsExtended) { return false; }
        }
        return true;
    }

    /*
     * Save whether your previous hands are opened
     * @param hands Leap.Hand[] both hands
     */
    public void SavePreviousHands(Hand[] hands) {
        if (hands[HandUtil.LEFT] != null) {
            //this.isOpenedPreviousHands[HandUtil.LEFT] = HandUtil.IsOpenedFiveFingers(hands[HandUtil.LEFT]);
            this.previousHands[HandUtil.LEFT] = hands[LEFT];
        }
        if (hands[HandUtil.RIGHT] != null) {
            //this.isOpenedPreviousHands[HandUtil.RIGHT] = HandUtil.IsOpenedFiveFingers(hands[HandUtil.RIGHT]);
            this.previousHands[HandUtil.RIGHT] = hands[RIGHT];
        }
        //Debug.Log("Left: " + this.isOpenedPreviousHands[HandUtil.LEFT]);
        //Debug.Log("Right: " + this.isOpenedPreviousHands[HandUtil.RIGHT]);
    }

    /*
     * Returns whether a hand is just opened from a state of closed hand
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @return whether it's opened (true or false)
     */
    public bool JustOpenedHandOn(Hand[] hands, int handId)
    {
        Hand hand = hands[handId];
        //過去手を閉じていて，現在の手が存在し，その手の指が全部開くとき
        if (!this.isOpenedPreviousHands[handId] && hand != null && HandUtil.IsOpenedFiveFingers(hand)) {
            this.isOpenedPreviousHands[handId] = true; //Just opened hand
            return true; //Opened
        }
        return false; //Not Opened
    }

    /*
     * Returns whether a hand is just closed from a state of opened hand
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @return whether it's opened (true or false)
     */
    public bool JustClosedHandOn(Hand[] hands, int handId)
    {
        Hand hand = hands[handId];
        //過去手を開いていて，現在の手が存在し，その手の指が全部閉じるとき
        if (this.isOpenedPreviousHands[handId] && hand != null && !HandUtil.IsOpenedFiveFingers(hand)) {
            this.isOpenedPreviousHands[handId] = false; //Just closed hand
            return true; //Closed
        }
        return false; //Not Closed
    }

    /*
    public static bool JustOpendIndexFinger(Hand hand) {
        foreach (Finger f in hand.Fingers) {
            if (f.IsExtended) {

            }
        }

    }
    */

    public static Vector3 GetVector3(Vector v) {
        return new Vector3(v.x, v.y, v.z);
    }
}
