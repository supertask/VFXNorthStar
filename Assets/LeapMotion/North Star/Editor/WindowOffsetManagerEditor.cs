/******************************************************************************
 * Copyright (C) Leap Motion, Inc. 2011-2018.                                 *
 *                                                                            *
 * Use subject to the terms of the Apache License 2.0 available at            *
 * http://www.apache.org/licenses/LICENSE-2.0, or another agreement           *
 * between Leap Motion and you, your company or other organization.           *
 ******************************************************************************/

using UnityEngine;
using UnityEditor;

namespace Leap.Unity.AR {

  [CustomEditor(typeof(WindowOffsetManager))]
  public class WindowOffsetManagerEditor : CustomEditorBase<WindowOffsetManager> {

    public override void OnInspectorGUI() {
      base.OnInspectorGUI();

      System.Type gameViewType = System.Type.GetType("UnityEditor.GameView,UnityEditor");

      if (GUILayout.Button("Move Game View to Headset")) {
        LayoutViews(gameViewType);
      }
      if (GUILayout.Button("Close All Game Views")) {
        CloseAllViews(gameViewType);
      }
    }

    // Instantiate and layout game views based on the setting.
    void LayoutViews(System.Type GameViewType) {
      CloseAllViews(GameViewType);

      EditorWindow view = (EditorWindow)CreateInstance(GameViewType);
      view.Show();
      ChangeTargetDisplay(view, 0);
      SendViewToScreen(view);
    }

    // Send a game view to a given screen.
    static void SendViewToScreen(EditorWindow view) {
      const int UNITY_MENU_HEIGHT = 22;
      var size = new Vector2(2160, 1200 + UNITY_MENU_HEIGHT);

      view.minSize = view.maxSize = size;
      Vector2 position = WindowOffsetManager.WindowShift
                         + Vector2Int.down * UNITY_MENU_HEIGHT;
      view.position = new Rect(position, size);
      EditorApplication.delayCall += () => {
        view.position = new Rect(position, view.position.size);
      };
    }

    // Change the target display of a game view.
    static void ChangeTargetDisplay(EditorWindow view, int displayIndex) {
      var serializedObject = new SerializedObject(view);
      var targetDisplay = serializedObject.FindProperty("m_TargetDisplay");
      targetDisplay.intValue = displayIndex;
      serializedObject.ApplyModifiedPropertiesWithoutUndo();
    }

    // Close all the game views.
    static void CloseAllViews(System.Type GameViewType) {
      foreach (EditorWindow view in Resources.FindObjectsOfTypeAll(GameViewType))
        view.Close();
    }
  }
}
