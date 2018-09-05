using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CastLit : MonoBehaviour {
	Material mat;
	int maskLayer;
	Transform theboneNode;
	// Use this for initialization
	void Start () {
		mat = this.GetComponent<Material>();
		maskLayer = LayerMask.GetMask ("Default");
		theboneNode = GameObject.Find("pelvis").transform;
	}
	Ray ray = new Ray();
	RaycastHit hit;
	LineRenderer gunLine;
	// Update is called once per frame
	void Update () {

		drawline();

		// drawline2();
	}

	LineRenderer gunLine2;
	List<GameObject> objList = new List<GameObject>();

	void drawline2(){

				gunLine2 = GetComponent <LineRenderer> ();
				if (gunLine2 == null) {
					gunLine2 = this.gameObject.AddComponent<LineRenderer> ();
					gunLine2.useWorldSpace = true;
					gunLine2.startWidth = .1f;
					gunLine2.endWidth = .2f;
					gunLine2.enabled = true;
					gunLine2.startColor = Color.red;
					gunLine2.endColor = Color.yellow;
					gunLine2.material = new Material(Shader.Find("Sprites/Default"));  
				 


					for (var i = 0 ; i < 20 ; i ++ ){
						var obj = new GameObject("go_"+i);
						obj.transform.position = new Vector3(theboneNode.transform.position.x + (float) i * .3f , theboneNode.transform.position.y,  0f);
						objList.Add(obj);

						FloatLinePoint point = obj.AddComponent<FloatLinePoint>();
			            if(i == 0){
			                point.preObj = this.gameObject;
			            }else{
			                point.preObj = objList[i - 1];
			            }
					}
				}

				//==== draw line ======
		 		Vector3[] vs = new Vector3[objList.Count];
		        for (int i = 0; i < objList.Count; i ++){
		            vs[i] = objList[i].transform.position;
		            Debug.Log(i + " ===> " + vs[i]);
		        }
		        gunLine2.positionCount = vs.Length;
		        gunLine2.SetPositions(vs);


	}
	public GameObject shadowObj;
	public Material shadowMat;
	void drawline(){
		var lineLength = 2f;
		gunLine = GetComponent <LineRenderer> ();
				if (gunLine == null) {
					gunLine = this.gameObject.AddComponent<LineRenderer> ();
					gunLine.useWorldSpace = true;
					gunLine.startWidth = .05f;
					gunLine.endWidth = .1f;
					gunLine.enabled = false;
					gunLine.startColor = Color.red;
					gunLine.endColor = Color.yellow;
					gunLine.material = new Material(Shader.Find("Sprites/Default"));  
				}


		ray.origin = theboneNode.transform.position;
		ray.direction =   theboneNode.transform.forward;//Vector3.down;//theboneNode.transform.forward * 1;

		// Debug.DrawLine (ray.origin, ray.origin + ray.direction * 1, Color.green);

		// var timeExist = 1f;
		// Debug.DrawRay(ray.origin,ray.direction , Color.red ,timeExist);
		//或
		Debug.DrawRay(ray.origin,ray.direction*lineLength , Color.white);


		//连接两个点
		gunLine.enabled = true;
		gunLine.SetPosition (0, ray.origin);  //射线起点
		gunLine.SetPosition (1, ray.origin+ray.direction *lineLength); //射线方向
		
	 
		
		if (Physics.Raycast (ray, out hit, lineLength, maskLayer)) {
			Debug.Log("========= "+hit.point);
			gunLine.startColor = Color.red;
			gunLine.endColor = Color.red;
			gunLine.SetPosition(1,  hit.point);

			if(shadowObj == null){
				shadowObj = GameObject.Find("comp_LOD_2");
				shadowMat = shadowObj.GetComponent<SkinnedMeshRenderer>().material;
			}
				shadowMat.SetFloat("_PlaneHeight",hit.point.y+.01f);

		}else{
			gunLine.startColor = Color.red;
			gunLine.endColor = Color.yellow;
		}
		
		// var origin = theboneNode.transform.position;
		// var direction =  theboneNode.transform.forward;
		// Debug.DrawLine(origin, direction , Color.yellow);
		// if(Physics.Raycast(origin, direction,out hit, 2 ,maskLayer)){
		// 	Debug.Log("hit:"+hit.point);
		// }

	}
	// void OnRenderImage (RenderTexture src, RenderTexture dest){
			//必需挂在相机上才有效，且是专业版 unity

	// }
}

 
 
public class FloatLinePoint : MonoBehaviour {
 
    public GameObject preObj;
 
    const float speed = 0.5f;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		var targetPoint = preObj.transform.position + new Vector3( .3f,0,0);
        transform.position   +=  (  targetPoint -  transform.position  ) * speed;
	}
}

