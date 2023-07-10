<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
	  <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option> 
        </config>
      </editWidget>
    </field>
    <field name="type" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option value="false" name="AllowMulti" type="bool"/>
            <Option value="true" name="AllowNull" type="bool"/>
            <Option value="data_model = 'Energy ADE 1.0' AND name = 'VolumeTypeValue'" name="FilterExpression" type="QString"/>
            <Option value="value" name="Key" type="QString"/>
            <Option value="ade3_v_enumeration_value_68f1969e_2427_48ea_8e94_09a3b8f41612" name="Layer" type="QString"/>
            <Option value="1" name="NofColumns" type="int"/>
            <Option value="true" name="OrderByValue" type="bool"/>
            <Option value="false" name="UseCompleter" type="bool"/>
            <Option value="description" name="Value" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="value" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
	  <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option> 
        </config>
      </editWidget>
    </field>
    <field name="value_uom" configurationFlags="None">
      <editWidget type="TextEdit">
        <config>
	  <Option type="Map">
            <Option name="IsMultiline" type="bool" value="false"/>
            <Option name="UseHtml" type="bool" value="false"/>
          </Option> 
        </config>
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" name="Database ID" index="0"/>
    <alias field="type" name="VolumeTypeValue" index="3"/>
    <alias field="value" name="Value" index="4"/>
    <alias field="value_uom" name="UoM" index="5"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="id" constraints="3" exp_strength="0" unique_strength="1"/>
    <constraint notnull_strength="0" field="value" constraints="4" exp_strength="1" unique_strength="0"/>
    <constraint notnull_strength="0" field="value_uom" constraints="4" exp_strength="1" unique_strength="0"/>
  </constraints>
  <constraintExpressions>
    <constraint field="value" desc="Both values must either be NULL or NOT NULL" exp="(&quot;value&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;value_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;value&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;value_uom&quot; IS NULL)"/>
    <constraint field="value_uom" desc="Both values must either be NULL or NOT NULL" exp="(&quot;value&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;value_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;value&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;value_uom&quot; IS NULL)"/>
</constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorField name="id" showLabel="1" index="1"/>
    <attributeEditorField name="type" showLabel="1" index="2"/>
    <attributeEditorField name="value" showLabel="1" index="3"/>
    <attributeEditorField name="value_uom" showLabel="1" index="4"/>
  </attributeEditorForm>
  <editable>
    <field name="id" editable="0"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
