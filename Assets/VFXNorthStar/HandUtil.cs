using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;

public enum HandActionType: int { JUST_OPENED, JUST_CLOSED }
public enum FingerActionType: int { JUST_OPENED, JUST_CLOSED }
public enum HandStatus : int { OPEN, CLOSE, UNKNOWN }

public class HandUtil
{
    public static int LEFT = 0;
    public static int RIGHT = 1;
    private bool[] isOpenedPreviousHands;
    private bool[,] isOpenedPreviousFingers;
    private int[] handIds;

    public HandUtil() {
        this.isOpenedPreviousHands = new bool[2];
        this.isOpenedPreviousHands.Fill(false);
        this.isOpenedPreviousFingers = new bool[2, 6]; //thumb, index, middle, ring, pinky, unknown
        this.isOpenedPreviousFingers.Fill(false);
        this.handIds = new int[2] { HandUtil.LEFT, HandUtil.RIGHT };
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
     * Returns whether the hand is grabbed (four fingers are closed).
     *
     * Check out GrabStreangth variable of Hand class
     * https://leapmotion.github.io/UnityModules/class_leap_1_1_hand.html#ae3b86d4d13139d772be092b6838ee9b5
     */
    public static HandStatus GetHandStatus(Hand hand)
    {
        //The strength is zero for an open hand
        if (hand.GrabStrength == 0.0f) { return HandStatus.OPEN; }
        else if (hand.GrabStrength == 1.0f) { return HandStatus.CLOSE; }
        else { return HandStatus.UNKNOWN; }
    }

    /*
     * Save whether your previous hands are opened
     * @param hands Leap.Hand[] both hands
     */
    public void SavePreviousHands(Hand[] hands)
    {
        foreach(int handId in this.handIds) {
            Hand hand = hands[handId];
            if (hand != null) {
                if (HandUtil.GetHandStatus(hand) == HandStatus.OPEN) {
                    this.isOpenedPreviousHands[handId] = true;
                }
                else if (HandUtil.GetHandStatus(hand) == HandStatus.CLOSE) {
                    this.isOpenedPreviousHands[handId] = false;
                }
                else { } //何も保存しない
            }
        }
        //Debug.Log("Left: " + this.isOpenedPreviousHands[HandUtil.LEFT]);
        //Debug.Log("Right: " + this.isOpenedPreviousHands[HandUtil.RIGHT]);
    }

    /*
     * Save whether your previous fingers are opened
     * @param hands Leap.Hand[] both hands
     */
    public void SavePreviousFingers(Hand[] hands)
    {
        foreach (int handId in this.handIds) {
            Hand hand = hands[handId];
            if (hand != null) {
                foreach (Finger f in hand.Fingers) {
                    this.isOpenedPreviousFingers[handId, (int)f.Type] = f.IsExtended;
                }
            }
        }
    }

    /*
     * Returns whether a hand is just opened from a state of closed hand
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @return whether it's opened (true or false)
     */
    public bool JustOpenedHandOn(Hand[] hands, int handId) {
        return this.JustActionedHandOn(hands, handId, HandActionType.JUST_OPENED);
    }

    /*
     * Returns whether a hand is just closed from a state of opened hand
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @return whether it's opened (true or false)
     */
    public bool JustClosedHandOn(Hand[] hands, int handId) {
        return this.JustActionedHandOn(hands, handId, HandActionType.JUST_CLOSED);
    }

    /*
     * Returns whether a hand is "just opened" or "just closed" from a state of closed or opened hand
     *
     * Called by JustOpenedHandOn  or JustClosedHandOn 
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @param actionType: Hand just opened action or Hand just closed action
     * @return whether the action is started (true or false)
     */
    private bool JustActionedHandOn(Hand[] hands, int handId, HandActionType actionType) {
        Hand hand = hands[handId];
        //過去手を開いていて，現在の手が存在し，その手の指が全部閉じるとき
        if (hand != null) {
            switch (actionType) {
                case HandActionType.JUST_OPENED:
                    //Whether the hand is just opened
                    if ( ! this.isOpenedPreviousHands[handId] && HandUtil.GetHandStatus(hand) == HandStatus.OPEN) {
                        this.isOpenedPreviousHands[handId] = true; //hand status
                        return true; //Just opened
                    }
                    break;
                case HandActionType.JUST_CLOSED:
                    //Whether the hand is just closed
                    if (this.isOpenedPreviousHands[handId] && HandUtil.GetHandStatus(hand) == HandStatus.CLOSE) {
                        this.isOpenedPreviousHands[handId] = false; //hand status
                        return true; //Just closed
                    }
                    break;
            }
        }
        return false; //Not Actioned
    }

    /*
     * Returns whether a finger is "just opened" from a state of closed finger
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @param fingerId: Leap.Finger.FingerType 0 ~ 4 (thumb finger to pinky finger)
     * @return whether it's just opened (true or false)
     */
    public bool JustOpenedFingerOn(Hand[] hands, int handId, int fingerId) {
        return this.JustActionedFingerOn(hands, handId, fingerId, FingerActionType.JUST_OPENED);
    }

    /*
     * Returns whether a finger is "just closed" from a state of opened finger
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @param fingerId: Leap.Finger.FingerType 0 ~ 4 (thumb finger to pinky finger)
     * @return whether it's just closed (true or false)
     */
    public bool JustClosedFingerOn(Hand[] hands, int handId, int fingerId) {
        return this.JustActionedFingerOn(hands, handId, fingerId, FingerActionType.JUST_CLOSED);
    }

    /*
     * Returns whether a finger is "just opened" or "just closed" from a state of closed or opened finger
     *
     * Called by JustOpenedFingerOn  or JustClosedFingerOn 
     * @param hand: LeapMotion Hand Model
     * @param handId: HandUtil.LEFT(=0) or HandUtil.RIGHT(=1)
     * @param fingerId: Leap.Finger.FingerType 0 ~ 4 (thumb finger to pinky finger)
     * @param actionType: Hand just opened action or Hand just closed action
     * @return whether the action is started (true or false)
     */
    private bool JustActionedFingerOn(Hand[] hands, int handId, int fingerId, FingerActionType actionType) {
        Hand hand = hands[handId];
        if (hand != null) {
            Finger finger = hands[handId].Fingers[fingerId];
            switch(actionType) {
                case FingerActionType.JUST_OPENED:
                     //Whether the finger is just opened
                    if  ( ! this.isOpenedPreviousFingers[handId, fingerId] && finger.IsExtended) {
                        this.isOpenedPreviousFingers[handId, fingerId] = true; //opened status
                        return true; //just opened?
                    }
                    break;
                case FingerActionType.JUST_CLOSED:
                     //Whether the finger is just closed
                    if (this.isOpenedPreviousFingers[handId, fingerId] && ! finger.IsExtended) {
                        this.isOpenedPreviousFingers[handId, fingerId] = false; //closed status
                        return true; //just closed?
                    }
                    break;
            }
        }
        return false; //No actioned
    }
    

    public static Vector3 GetVector3(Vector v) {
        return new Vector3(v.x, v.y, v.z);
    }
    
    public static Quaternion GetQuaternion(LeapQuaternion q) {
        return new Quaternion(q.x, q.y, q.z, q.w);
    }
}
