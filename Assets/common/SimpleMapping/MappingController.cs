using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MappingController : MonoBehaviour
{
    SimpleMapper mapper;

    void Start()
    {
        this.mapper = new SimpleMapper();
    }

    void Update()
    {
        if (SceneManager.GetActiveScene().name == "SimpleMapping") {
            if (Input.GetKeyUp(KeyCode.B)) {
                Debug.Log("Key B");
                this.mapper.CreateBox(); //マップするボックス作成
            }
            else if (Input.GetKeyUp(KeyCode.E)) {
                Debug.Log("Key E");
                this.mapper.Save(); //マッピング終了
                //SceneManager.LoadScene("Force");
            }
        }
    }
}
