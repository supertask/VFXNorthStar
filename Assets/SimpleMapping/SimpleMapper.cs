using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SimpleMapper 
{
    private GameObject originBox;
    private GameObject mapped;
    private GameObject selecting;
    private GameObject field;

    // Start is called before the first frame update
    public SimpleMapper()
    {
        this.mapped = GameObject.Find("Mapped");
        this.originBox = GameObject.Find("OriginCube");
        this.selecting = GameObject.Find("Selecting");
        this.field = GameObject.Find("Field");
        this.Load();
    }

    /*
     * セーブデータを読み込む
     */
    public void Load()
    {
        bool is_shown_map = (SceneManager.GetActiveScene().name == "SimpleMapping");

        if (PlayerPrefs.HasKey("mappedPosList"))
        {
            if (this.mapped.transform.childCount > 0) {
                foreach(Transform child in this.mapped.transform) { GameObject.Destroy(child.gameObject); }
            }
            Vector3[] posList = PlayerPrefsX.GetVector3Array("mappedPosList");
            Quaternion[] rotList = PlayerPrefsX.GetQuaternionArray("mappedRotList");
            Vector3[] scaleList = PlayerPrefsX.GetVector3Array("mappedScaleList");
            for(int i = 0; i < posList.Length; i++)
            {
                GameObject obj = Object.Instantiate(this.originBox) as GameObject;
                obj.transform.position = posList[i];
                obj.transform.rotation = rotList[i];
                obj.transform.localScale = scaleList[i];
                obj.transform.parent = this.mapped.transform;
                obj.GetComponent<Renderer>().enabled = is_shown_map;
            }
        }
        else {
            //セーブデータがない場合，何もしない
        }
    }

    //boxを作成
    public void CreateBox() {
            this.MapSelectedObjects(); //選択したオブジェクトをマッピングする
            Vector3 p = this.originBox.transform.position;
            GameObject box = Object.Instantiate(originBox) as GameObject; //コピー
            box.transform.position = p;
            box.GetComponent<Renderer>().enabled = true;
            box.transform.parent = this.selecting.transform;
    }

    /*
     * 選択したオブジェクトをマップ済みオブジェクトへ登録する
     */
    private void MapSelectedObjects() {
        foreach(Transform child in this.selecting.transform) {
            child.parent = this.mapped.transform;
        }
    }

    /*
     * データをPlayerPrefsXに保存する
     */
    public void Save()
    {
        this.MapSelectedObjects(); //選択したオブジェクトをマッピングする
        List<Vector3> savingPosList = new List<Vector3>() { };
        List<Quaternion> savingRotList = new List<Quaternion>() { };
        List<Vector3> savingScaleList = new List<Vector3>() { };
        foreach(Transform transform in this.mapped.transform) {
            savingPosList.Add(transform.position);
            savingRotList.Add(transform.rotation);
            savingScaleList.Add(transform.localScale);
        }
        PlayerPrefsX.SetVector3Array("mappedPosList", savingPosList.ToArray());
        PlayerPrefsX.SetQuaternionArray("mappedRotList", savingRotList.ToArray());
        PlayerPrefsX.SetVector3Array("mappedScaleList", savingScaleList.ToArray());
    }

    void OnApplicationQuit()
    {
    }
}
