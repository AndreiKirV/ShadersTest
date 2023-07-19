using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class USBReplacementController : MonoBehaviour
{
    // replacement shader
    public Shader m_replacementShader;
    private void OnEnable()
    {
        if (m_replacementShader != null)
        {
            GetComponent<Camera>().SetReplacementShader(m_replacementShader, "");
        }
    }
    private void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }
}