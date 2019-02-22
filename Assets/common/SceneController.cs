using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneController : MonoBehaviour
{
    SimpleMapper mapper;

    void Start()
    {
        this.mapper = new SimpleMapper();
    }

    void Update()
    {
        if (Input.GetKeyUp(KeyCode.Alpha1)) {
            this.ChangeScene("Force");
        } else if (Input.GetKeyUp(KeyCode.Alpha2)) {
            this.ChangeScene("LightningOnNorthStar");
        } else if (Input.GetKeyUp(KeyCode.Alpha3)) {
            this.ChangeScene("SimpleMapping");
        } else if (Input.GetKeyUp(KeyCode.Alpha4)) {
            ///this.ChangeScene("Trail");
        }
    }

    public void ChangeScene(string sceneName) {
        if (SceneManager.GetActiveScene().name == sceneName) { return; }
        SceneManager.LoadScene(sceneName);
        //this.mapper.Load();
    }
}
