using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Rewired;

public class InputTesting : MonoBehaviour
{
    public int playerId = 0;
    private Player player;

    public float Horizontal;
    public float Vertical;

    void Awake()
    {
        player = ReInput.players.GetPlayer(playerId);
    }

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Horizontal = player.GetAxisRaw(0);
        Vertical = player.GetAxisRaw(1);
    }
}
